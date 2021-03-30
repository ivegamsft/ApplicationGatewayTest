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
variable "frontend_subnet_id" {
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

# Local Variables for use in the module because there is lots of reuse
locals {
  backend_address_pool_name      = "${var.base_name}-beap"
  frontend_port_name             = "${var.base_name}-feport"
  frontend_ip_configuration_name = "${var.base_name}-feip"
  http_setting_name              = "${var.base_name}-be-htst"
  listener_name                  = "${var.base_name}-httplstn"
  request_routing_rule_name      = "${var.base_name}-rqrt"
  redirect_configuration_name    = "${var.base_name}-rdrcfg"
}

# Module
resource "azurerm_application_gateway" "ag" {
  name                = "${var.base_name}-ag"
  resource_group_name = var.resource_group.name
  location            = var.resource_group.region

  sku {
    name     = var.sku_name
    tier     = var.sku_tier
    capacity = var.sku_capacity
  }

  gateway_ip_configuration {
    name      = "${var.base_name}-gateway-ip-config"
    subnet_id = var.frontend_subnet_id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = var.pip_id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/api1/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 1
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}
