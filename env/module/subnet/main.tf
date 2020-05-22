# Base variables
variable "name" {}
variable "resource_group_name" {}

# Network variables
variable "virtual_network_name" {}
variable "address_prefixes" {}

# Module
resource "azurerm_subnet" "subnet" {
  name = var.name

  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = ["${var.address_prefixes}"]
}

#Output
output "id" {
  value = azurerm_subnet.subnet.id
}
