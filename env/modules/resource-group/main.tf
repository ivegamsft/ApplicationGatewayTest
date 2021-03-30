variable "base_name" {
  description = "Base name to use for the resources"
  type        = string
}

variable "region" {
  description = "region to deploy"
  type        = string
}

variable "tags" {
  description = "Map of tags to set on resources"
  type        = map(string)
  default     = {}
}

locals {
  rg_name = format("%s-rg", var.base_name)
}

output "resource_group" {
  value = ({
    id     = azurerm_resource_group.rg.id
    name   = local.rg_name
    region = var.region
  })
}

resource "azurerm_resource_group" "rg" {
  name     = local.rg_name
  location = var.region
  tags     = var.tags
}
