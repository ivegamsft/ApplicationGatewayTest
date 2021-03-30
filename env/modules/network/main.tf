## variables
variable "base_name" {
  description = "the base name for the resources"
  type        = string
}

variable "resource_group" {
  description = "The RG"
  type = object({
    id     = string
    name   = string
    region = string
  })
}

variable "vnet_address_space" {
  description = "Vnet range"
  type        = string
}

variable "tags" {
  description = "Map of tags to set on resources"
  type        = map(string)
  default     = {}
}

## outputs
output "vnet" {
  value = azurerm_virtual_network.vnet
}
output "app_gw_subnet" {
  value = azurerm_subnet.app_gw_subnet
}
output "vm_subnet" {
  value = azurerm_subnet.vm_subnet
}
output "bastion_subnet" {
  value = azurerm_subnet.bastion_subnet
}

## locals
locals {
  #Carve the subnets that are required for the network
  app_gw_subnet_prefix  = cidrsubnet(var.vnet_address_space, 3, 1)
  vm_subnet_prefix      = cidrsubnet(var.vnet_address_space, 3, 0)
  bastion_subnet_prefix = cidrsubnet(var.vnet_address_space, 4, 4)
}

## Modules
resource "azurerm_virtual_network" "vnet" {
  name                = format("%s-vnet", var.base_name)
  address_space       = [var.vnet_address_space]
  location            = var.resource_group.region
  resource_group_name = var.resource_group.name
}

resource "azurerm_subnet" "app_gw_subnet" {
  name                 = format("%s-appgw-subnet", var.base_name)
  resource_group_name  = var.resource_group.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [local.app_gw_subnet_prefix]
}

resource "azurerm_subnet" "vm_subnet" {
  name                 = format("%s-vm-subnet", var.base_name)
  resource_group_name  = var.resource_group.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [local.vm_subnet_prefix]
}

resource "azurerm_subnet" "bastion_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [local.bastion_subnet_prefix]
}

### Netapp BH
resource "azurerm_public_ip" "bh_pip" {
  name                = format("%s-bh-pip", var.base_name)
  resource_group_name = var.resource_group.name
  location            = var.resource_group.region
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "bh" {
  name                = format("%s-bh", var.base_name)
  resource_group_name = var.resource_group.name
  location            = var.resource_group.region

  ip_configuration {
    name                 = "ipcfg"
    subnet_id            = azurerm_subnet.bastion_subnet.id
    public_ip_address_id = azurerm_public_ip.bh_pip.id
  }
}
