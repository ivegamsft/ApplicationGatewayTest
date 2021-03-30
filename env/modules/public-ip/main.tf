# Base Variables
variable "base_name" {
  type = string
}
variable "resource_group" {
  description = "The RG"
  type = object({
    id     = string
    name   = string
    region = string
  })
}
variable "tags" {
  description = "Map of tags to set on resources"
  type        = map(string)
  default     = {}
}

# Public IP Variables
variable "allocation_method" {
  type    = string
  default = "Static"
}

variable "sku" {
  type    = string
  default = "Standard"
}

# Module
resource "azurerm_public_ip" "pip" {
  name                = "${var.base_name}-pip"
  location            = var.resource_group.region
  resource_group_name = var.resource_group.name
  allocation_method   = var.allocation_method
  sku                 = var.sku
  tags                = var.tags
}

# Output
output "id" {
  value = azurerm_public_ip.pip.id
}
