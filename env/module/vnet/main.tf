variable "name" {}
variable "location" {}
variable "resource_group_name" {}
variable "address_space" {}

variable "tags" {}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.name}-vnet"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["${var.address_space}"]

  tags = var.tags
}

output "name" {
  value = azurerm_virtual_network.vnet.name
}
