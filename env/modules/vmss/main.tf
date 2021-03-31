## variables
variable "base_name" {
  description = "Base name to use for the resources"
  type        = string
}

variable "resource_group" {
  description = "The RG"
  type = object({
    id     = string
    region = string
    name   = string
  })
}

variable "vm_size" {
  description = "VM Size"
  type        = string
  default     = "Standard_DS3_v2"
}
variable "instance_count" {
  description = "VMSS Instance count"
  type        = number
  default     = 2
}

variable "subnet_id" {
  description = "Subnet to use for the vms"
  type        = string
}

variable "diag_stg_acct_id" {
  description = "The diag storage account id for the VMs"
  type        = string
}

variable "admin_username" {
  description = "user name for the VMs"
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "user name for the VMs"
  type        = string
}

## outputs

## locals
locals {
}

## resources

### VMS
module "windows_vmss" {
  source           = "./windows/"
  resource_group   = var.resource_group
  subnet_id        = var.subnet_id
  base_name        = var.base_name
  diag_stg_acct_id = var.diag_stg_acct_id
  vm_size          = var.vm_size
  instance_count = var.instance_count
  admin_username   = var.admin_username
  admin_password   = var.admin_password
}

# module "linux_vmss" {
#   source           = "./linux/"
#   resource_group   = var.resource_group
#   subnet_id        = var.subnet_id
#   base_name        = var.base_name
#   diag_stg_acct_id = var.diag_stg_acct_id
#   vm_size          = var.vm_size
# }
