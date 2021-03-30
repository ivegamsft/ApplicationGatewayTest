# Provider block variables set as GitHub secrets at action time
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Base Variables pulled from ./variables.tfvars file
variable "base_name" {
  description = "Base name to use for the resources"
  type        = string
  default     = "random"
}
variable "region" {
  type = string
}
variable "tags" {
  description = "Map of tags to set on resources"
  type        = map(string)
  default     = {}
}
variable "vnet_address_space" {
  type = string
}
variable "admin_username" {
  type    = string
  default = "azureuser"
}
variable "admin_password" {
  type    = string
  default = "random"
}
variable "ag_pip_allocation_method" {
  type    = string
  default = "Dynamic"
}
variable "ag_sku_name" {
  type = string
}
variable "ag_sku_tier" {
  type = string
}
variable "ag_sku_capacity" {
  type = number
}

## outputs
output "generated_password" {
  value = local.admin_password
}

## locals
locals {
  base_name      = var.base_name == "random" ? random_string.base_id.result : var.base_name
  admin_password = var.admin_password == "random" ? random_string.generated_password.result : var.admin_password
}

# Base Resources
resource "random_string" "base_id" {
  length  = 5
  special = false
  upper   = false
  number  = true
}

resource "random_string" "generated_password" {
  length  = 16
  special = true
  upper   = true
  number  = true
}

module "rg" {
  source    = "./modules/resource-group/"
  base_name = local.base_name
  region    = var.region
  tags      = var.tags
}

# Network Resources built from modules
module "network" {
  source             = "./modules/network/"
  base_name          = local.base_name
  resource_group     = module.rg.resource_group
  vnet_address_space = var.vnet_address_space
  tags               = var.tags
}

module "vm_stg" {
  source         = "./modules/storage/"
  base_name      = local.base_name
  resource_group = module.rg.resource_group
}

module "vms" {
  source           = "./modules/vms/"
  base_name        = local.base_name
  resource_group   = module.rg.resource_group
  subnet_id        = module.network.vm_subnet.id
  diag_stg_acct_id = module.vm_stg.diag_stg.id
  admin_username   = var.admin_username
  admin_password   = local.admin_password

}

## Public IP
module "app_gateway_pip" {
  source            = "./modules/public-ip/"
  base_name         = format("%s-app-gw-pip", local.base_name)
  resource_group    = module.rg.resource_group
  allocation_method = var.ag_pip_allocation_method
  sku               = "Basic"
  tags              = var.tags
}

# Application Gateway
module "app_gateway" {
  source             = "./modules/app-gateway/"
  base_name          = local.base_name
  resource_group     = module.rg.resource_group
  tags               = var.tags
  frontend_subnet_id = module.network.app_gw_subnet.id
  sku_name           = var.ag_sku_name
  sku_tier           = var.ag_sku_tier
  sku_capacity       = var.ag_sku_capacity
  pip_id             = module.app_gateway_pip.id
}
