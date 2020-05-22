# Base Variables
variable "name" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "location" {
  type = string
}
variable "tags" {}

# Public IP Variables
variable "allocation_method" {
  type = string
}

# Module
resource "azurerm_public_ip" "pip" {
  name                = "${var.name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = var.allocation_method

  tags = var.tags
}

# Output
output "id" {
  value = azurerm_public_ip.pip.id
}
