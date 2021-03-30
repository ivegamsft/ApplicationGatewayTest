## variables
variable "base_name" {
  description = "Base name to use for the resources"
  type        = string
}

variable "resource_group" {
  description = "The RG for the vm"
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
variable "vm_count" {
  description = "VM Count"
  type        = number
  default     = 1
}

variable "subnet_id" {
  description = "Subnet to use for the vm"
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
  vm_base_name    = format("%s-iis", var.base_name)
  vm_count        = var.vm_count
  data_disk_count = 1
  vm_publisher    = "MicrosoftWindowsServer"
  vm_offer        = "WindowsServer"
  vm_sku          = "2019-Datacenter"
  vm_version      = "latest"
}

## resources

resource "azurerm_network_interface" "nics" {
  count                         = local.vm_count
  name                          = format("%s%d-nic", local.vm_base_name, count.index)
  resource_group_name           = var.resource_group.name
  location                      = var.resource_group.region
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "ipcnfg"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_managed_disk" "disks" {
  count                = local.data_disk_count
  name                 = format("%s%d-data-%d", local.vm_base_name, count.index, count.index)
  resource_group_name  = var.resource_group.name
  location             = var.resource_group.region
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 1024
}

resource "azurerm_windows_virtual_machine" "vms" {
  count               = local.vm_count
  name                = format("%s%d", local.vm_base_name, count.index)
  resource_group_name = var.resource_group.name
  location            = var.resource_group.region
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.nics[count.index].id,
  ]

  os_disk {
    name                 = format("%s%d-os", local.vm_base_name, count.index)
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = local.vm_publisher
    offer     = local.vm_offer
    sku       = local.vm_sku
    version   = local.vm_version
  }
}

# //TODO: Loop through each machine and each disk to attach them
# resource "azurerm_virtual_machine_data_disk_attachment" "data_disks" {
#   count              = local.data_disk_count
#   managed_disk_id    = azurerm_managed_disk.disks[count.index].id
#   virtual_machine_id = azurerm_linux_virtual_machine.vms[count.index].id
#   lun                = count.index
#   caching            = "None"
# }

# resource "azurerm_virtual_machine_extension" "vm_depagent" {
#   count                      = local.vm_count
#   name                       = format("%s%d-daext", local.vm_base_name, count.index)
#   virtual_machine_id         = azurerm_windows_virtual_machine.vms[count.index].id
#   publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
#   type                       = "DependencyAgentWindows"
#   type_handler_version       = "9.5"
#   auto_upgrade_minor_version = true
# }

