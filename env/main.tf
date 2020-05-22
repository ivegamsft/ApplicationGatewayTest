# Provider block variables set as GitHub secrets at action time
variable "sub" {
  type = string
}
variable "client_id" {
  type = string
}
variable "client_secret" {
  type = string
}
variable "tenant_id" {
  type = string
}

# Azure RM Provider
provider "azurerm" {
  subscription_id = var.sub
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  features {}
}

# Base Variables pulled from ./variables.tfvars file
variable "base_name" {
  type = string
}
variable "location" {
  type = string
}
variable = "tags" {
  type = string
}

# Networking variables pulled from ./variables.tfvars file
variable "network_address_space" {
  type = string
}
variable "vms_address_space" {
  type = string
}
variable "appgateway_subnet_address_space" {
  type = string
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

# Base Resources
module "rg" {
  source = "./modules/resource-group"

  name     = var.base_name
  location = var.base_name

  tags = var.tags
}

# Network Resources built from modules
module "network" {
  source = "./modules/vnet"

  name                = "${var.base_name}-vnet"
  location            = var.location
  resource_group_name = module.rg.name
  address_space       = var.network_address_space

  tags = var.tags
}

## Subnets
module "vms_subnet" {
  source = "./modules/subnet"

  name                 = "vms"
  resource_group_name  = module.rg.name
  virtual_network_name = module.network.name
  address_prefixes     = var.vms_address_space
}

module "appgateway_subnet" {
  source = "./modules/subnet"

  name                 = "appgateway"
  resource_group_name  = module.rg.name
  virtual_network_name = module.network.name
  address_prefixes     = var.appgateway_subnet_address_space
}

## Public IP
module "pip" {
  source = "./module/public_ip "

  name = var.base_name
  location = var.location
  resource_group_name = module.rg.name
  allocation_method = var.allocation_method

  tags = var.tags
}

# Applicaton Gateway
module "app_gateway" {
  source = "./module/app-gateway"

  name = var.base_name
  location = var.location
  resource_group_name = module.rg.name

  tags = var.tags

  frontend_subnet_id = module.appgateway_subnet.id
  sku_name = var.ag_sku_name
  sku_tier = var.ag_sku_tier
  sku_capacity = var.ag_sku_capacity

  pip_id = module.pip.id
}