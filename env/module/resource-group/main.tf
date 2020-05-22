variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "tags" {
}

resource "azurerm_resource_group" "rg" {
  name     = var.name
  location = var.location

  tags = var.tags
}

output "name" {
  value = azurerm_resource_group.rg.name
}
