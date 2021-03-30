# Base Variables
base_name = "random"
region  = "westus2"

tags = {
  owner       = "me"
  environment = "demo"
}

# Networking Variables
vnet_address_space           = "10.100.0.0/20"

# Application Gateway Variables
ag_sku_name     = "Standard_Small"
ag_sku_tier     = "Standard"
ag_sku_capacity = 2
ag_pip_allocation_method = "Dynamic"

#VM info
admin_username  = "azureuser"
admin_password= "random"