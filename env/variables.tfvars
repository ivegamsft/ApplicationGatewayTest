# Base Variables
base_name = "appgatewaytest"
location  = "westus2"

tags = {
  owner       = "jogardn"
  environment = "demo"
  client      = "customer"
}

# Networking Variables
network_address_space           = "10.0.0.0/8"
vms_address_space               = "10.1.0.0/16"
appgateway_subnet_address_space = "10.2.1.0/24"

# Application Gateway Variables
ag_sku_name     = "Standard_Small"
ag_sku_tier     = "Standard"
ag_sku_capacity = 2

# Public IP Variables
allocation_method = "Static"
