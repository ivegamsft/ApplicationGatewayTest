###############################################################################
## Deploys storage accounts
###############################################################################

## variables
variable "base_name" {
  description = "Base name to use for the resources"
  type        = string
}

variable "resource_group" {
  description = "The RG for the storage account"
  type = object({
    id     = string
    region = string
    name   = string
  })
}

## outputs
output "diag_stg" {
  value = azurerm_storage_account.diag_stg
}

## locals
locals {
  base_name = var.base_name
}

## resources

resource "azurerm_storage_account" "diag_stg" {
  name                     = lower(format("%sdiagstg", var.base_name))
  resource_group_name      = var.resource_group.name
  location                 = var.resource_group.region
  account_tier             = "Standard"
  account_replication_type = "LRS"
}