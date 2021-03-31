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
variable "backend_subnet_id" {
  type = string
}
variable "sku_name" {
  type = string
}
variable "sku_tier" {
  type = string
}
variable "sku_capacity" {
  type = number
}
variable "pip_id" {
  type = string
}

output "app_gateway" {
  value = azurerm_application_gateway.ag
}
output "win_backend_address_pool_id" {
  value = azurerm_application_gateway.ag.backend_address_pool[0]
}
output "apache_backend_address_pool_id" {
  value = azurerm_application_gateway.ag.backend_address_pool[1]
}
output "tomcat_backend_address_pool_id" {
  value = azurerm_application_gateway.ag.backend_address_pool[2]
}
output "win_vmss_backend_address_pool_id" {
  value = azurerm_application_gateway.ag.backend_address_pool[3]
}
output "linux_vmss_backend_address_pool_id" {
  value = azurerm_application_gateway.ag.backend_address_pool[4]
}

# Local Variables for use in the module because there is lots of reuse
locals {
  app_gateway_name = format("%s-ag", var.base_name)

  frontend_port_name             = format("%s-feport", var.base_name)
  frontend_ip_configuration_name = format("%s-feip", var.base_name)
  listener_name                  = format("%s-httplstn", var.base_name)
  request_routing_rule_name      = format("%s-rqrt", var.base_name)
  redirect_configuration_name    = format("%s-rdrcfg", var.base_name)

  #Backend pools
  win_backend_address_pool_name        = "win-be-pool"
  apache_backend_address_pool_name     = "apache-be-pool"
  tomcat_backend_address_pool_name     = "tomcat-be-pool"
  win_vmss_backend_address_pool_name   = "winvmss-be-pool"
  linux_vmss_backend_address_pool_name = "linuxvmss-be-pool"

  #http settings
  http_setting_default        = "default"
  apache_http_setting_name    = "apache"
  tomcat_http_setting_name    = "tomcat"
  iis_http_setting_name       = "iis"
  winvmss_http_setting_name   = "win_vmss"
  linuxvmss_http_setting_name = "linux_vmss"

  #probes
  apache_probe_name         = "apache_http_probe"
  tomcat_probe_name         = "tomcat_http_probe"
  iis_probe_name            = "iis_http_probe"
  winvmss_http_probe_name   = "winvmss_http_probe"
  linuxvmss_http_probe_name = "linuxvmss_http_probe"
}

# Module
resource "azurerm_application_gateway" "ag" {
  name                = local.app_gateway_name
  resource_group_name = var.resource_group.name
  location            = var.resource_group.region

  sku {
    name = var.sku_name
    tier = var.sku_tier
    #capacity = var.sku_capacity
  }

  autoscale_configuration {
    min_capacity = 2
    max_capacity = 4
  }

  gateway_ip_configuration {
    name      = format("%s-gateway-ip-config", var.base_name)
    subnet_id = var.backend_subnet_id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = var.pip_id
  }

  #Backend Pools
  backend_address_pool {
    name = local.win_backend_address_pool_name
  }
  backend_address_pool {
    name = local.apache_backend_address_pool_name
  }
  backend_address_pool {
    name = local.tomcat_backend_address_pool_name
  }
  backend_address_pool {
    name = local.win_vmss_backend_address_pool_name
  }
  backend_address_pool {
    name = local.linux_vmss_backend_address_pool_name
  }


  #Listeners
  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  #Backend HTTPS Settings
  ## Apache
  backend_http_settings {
    name                                = local.apache_http_setting_name
    cookie_based_affinity               = "Enabled"
    affinity_cookie_name                = substr(base64sha256(local.apache_http_setting_name), 0, 9)
    port                                = 80
    protocol                            = "Http"
    request_timeout                     = 600
    pick_host_name_from_backend_address = true
    #probe_name                          = local.apache_probe_name
    #host_name             = local.ag_be_host_name
  }

  ##Tomcat
  backend_http_settings {
    name                                = local.tomcat_http_setting_name
    cookie_based_affinity               = "Enabled"
    affinity_cookie_name                = substr(base64sha256(local.tomcat_http_setting_name), 0, 9)
    port                                = 80
    protocol                            = "Http"
    request_timeout                     = 600
    pick_host_name_from_backend_address = true
    #probe_name                          = local.tomcat_probe_name
    #host_name             = local.ag_be_host_name
  }
  ##IIS
  backend_http_settings {
    name                                = local.iis_http_setting_name
    cookie_based_affinity               = "Enabled"
    affinity_cookie_name                = substr(base64sha256(local.iis_http_setting_name), 0, 9)
    port                                = 80
    protocol                            = "Http"
    request_timeout                     = 600
    pick_host_name_from_backend_address = true
    #probe_name                          = local.iis_probe_name
    #host_name             = local.ag_be_host_name
  }

  ##Win VMSS
  backend_http_settings {
    name                                = local.winvmss_http_setting_name
    cookie_based_affinity               = "Enabled"
    affinity_cookie_name                = substr(base64sha256(local.winvmss_http_setting_name), 0, 9)
    port                                = 80
    protocol                            = "Http"
    request_timeout                     = 600
    pick_host_name_from_backend_address = true
    #probe_name                          = local.winvmss_http_probe_name
    #host_name             = local.ag_be_host_name
  }

  ##Linux VMSS
  backend_http_settings {
    name                  = local.linuxvmss_http_setting_name
    cookie_based_affinity = "Enabled"
    affinity_cookie_name  = substr(base64sha256(local.linuxvmss_http_setting_name), 0, 9)
    port                  = 80
    protocol              = "Http"
    request_timeout       = 600
    #probe_name                          = local.linuxvmss_http_probe_name
    pick_host_name_from_backend_address = true
    #host_name             = local.ag_be_host_name
  }

  #Probes
  ##Apache probe
  probe {
    name                                      = local.apache_probe_name
    protocol                                  = "http"
    path                                      = "/"
    interval                                  = 5
    timeout                                   = 16
    unhealthy_threshold                       = 3 # 0-20
    pick_host_name_from_backend_http_settings = true
    #host                = local.ag_be_host_name
    match {
      #body        = "Health Check successful!"
      status_code = ["200-399"]
    }
  }

  # ##Tomcat probe
  probe {
    name                                      = local.tomcat_probe_name
    protocol                                  = "http"
    path                                      = "/"
    interval                                  = 5
    timeout                                   = 16
    unhealthy_threshold                       = 3 # 0-20
    pick_host_name_from_backend_http_settings = true
    #host                = local.ag_be_host_name
    match {
      #body        = "Health Check successful!"
      status_code = ["200-399"]
    }
  }

  # ##IIS probe
  probe {
    name                                      = local.iis_probe_name
    protocol                                  = "http"
    path                                      = "/"
    interval                                  = 5
    timeout                                   = 16
    unhealthy_threshold                       = 3 # 0-20
    pick_host_name_from_backend_http_settings = true
    #host                = local.ag_be_host_name
    match {
      #body        = "Health Check successful!"
      status_code = ["200-399"]
    }
  }

  # #Win VMSS probe
  probe {
    name                                      = local.winvmss_http_probe_name
    protocol                                  = "http"
    path                                      = "/"
    interval                                  = 5
    timeout                                   = 16
    unhealthy_threshold                       = 3 # 0-20
    pick_host_name_from_backend_http_settings = true
    #host                = local.ag_be_host_name
    match {
      #body        = "Health Check successful!"
      status_code = ["200-399"]
    }
  }

  # ##Linux VMSS probe
  probe {
    name                                      = local.linuxvmss_http_probe_name
    protocol                                  = "http"
    path                                      = "/"
    interval                                  = 5
    timeout                                   = 16
    unhealthy_threshold                       = 3 # 0-20
    pick_host_name_from_backend_http_settings = true
    #host                = local.ag_be_host_name
    match {
      #body        = "Health Check successful!"
      status_code = ["200-399"]
    }
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.apache_backend_address_pool_name
    backend_http_settings_name = local.apache_http_setting_name
  }

  #Wire up the urls to the path rules for default
  # url_path_map {
  #   name                               = local.ag_default_path_map_name
  #   default_backend_address_pool_name  = local.ag_default_backend_address_pool_name
  #   default_backend_http_settings_name = local.ag_apache_http_settings_name
  #   default_rewrite_rule_set_name      = local.ag_rewrite_rule_set_name

  #   path_rule {
  #     name                       = "bms_rule"
  #     paths                      = ["/bms/*"]
  #     backend_address_pool_name  = local.ag_bms_backend_address_pool_name
  #     backend_http_settings_name = local.ag_bms_http_settings_name
  #     rewrite_rule_set_name      = local.ag_rewrite_rule_set_name
  #   }
  #   path_rule { //Temp rule to allow for Http2BMS end-to-end tls testing.
  #     name                       = "bmss_rule"
  #     paths                      = ["/bmss/*"]
  #     backend_address_pool_name  = local.ag_bms_backend_address_pool_name
  #     backend_http_settings_name = local.ag_bms_https_settings_name
  #     rewrite_rule_set_name      = local.ag_rewrite_rule_set_name
  #   }
  #   path_rule {
  #     name                       = "api_gateway"
  #     paths                      = ["/api/*", "/web/*"]
  #     backend_address_pool_name  = local.ag_default_backend_address_pool_name
  #     backend_http_settings_name = local.ag_api_http_settings_name
  #     rewrite_rule_set_name      = local.ag_rewrite_rule_set_name
  #   }
  #   path_rule {
  #     name                       = "api_gateway_uat"
  #     paths                      = ["/api/uat/*"]
  #     backend_address_pool_name  = local.ag_default_backend_address_pool_name
  #     backend_http_settings_name = local.ag_api_uat_http_settings_name
  #     rewrite_rule_set_name      = local.ag_rewrite_rule_set_name
  #   }
  # }
}
