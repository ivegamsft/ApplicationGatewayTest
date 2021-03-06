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
  description = "VM Count"
  type        = number
  default     = 1
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
  vmss_base_name    = substr(format("%srhvmss", var.base_name), 0, 8)
  vm_count        = var.vm_count
  data_disk_count = 1
  vm_publisher    = "RedHat"
  vm_offer        = "RHEL"
  vm_sku          = "7.7"
  vm_version      = "latest"
}

## resources

### VMSS
resource "azurerm_linux_virtual_machine_scale_set" "linux_vmss" {
  name                = local.vmss_base_name
  resource_group_name = var.resource_group.name
  location            = var.resource_group.region
  sku                 = var.vm_size
  instances           = var.instance_count
  admin_username      = var.admin_username

  #   admin_ssh_key {
  #     username   = "adminuser"
  #     public_key = file("~/.ssh/id_rsa.pub")
  #   }

  source_image_reference {
    publisher = local.vm_publisher
    offer     = local.vm_offer
    sku       = local.vm_sku
    version   = local.vm_version
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = format("%s-vmss-nic", local.vmss_base_name)
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = var.subnet_id
    }
  }
}
