resource "azurerm_subnet" "agw-subnets" {
  name                 = "agw-subnets"
  resource_group_name  = azurerm_resource_group.agw-rg.name
  virtual_network_name = azurerm_virtual_network.agw-rg-vnet.name
  address_prefixes     = ["10.30.1.0/24"]
}

resource "azurerm_application_gateway" "network" {

  ############################################
  #####     BASICS                       #####
  ############################################
  name                = "example-appgateway"
  resource_group_name = azurerm_resource_group.agw-rg.name
  location            = azurerm_resource_group.agw-rg.location

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 1

  }
  waf_configuration {
    enabled          = true
    firewall_mode    = "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.2"

  }
  # assign agw subnet id here
  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.agw-subnets.id
  }
  ############################################
  #####     FRONT-END CONFIGURATION      #####
  ############################################
  frontend_port {
    name = "agw-fe-port"
    port = 80
  }

  # assign public ip to application gatewat
  frontend_ip_configuration {
    name                 = "feip"
    public_ip_address_id = azurerm_public_ip.agw-pubip-zone1.id
    # subnet_id                     = azurerm_subnet.agw-subnets.id
    # private_ip_address_allocation = "Static"
    # private_ip_address            = "10.30.1.100"
    # type                          = "Both"
  }

  ############################################
  #####     backend_address_pool         #####
  ############################################

  backend_address_pool {
    name         = "homepage"
    ip_addresses = [azurerm_network_interface.vm-nic-zone1.private_ip_address]
  }

  backend_address_pool {
    name         = "movies"
    ip_addresses = [azurerm_network_interface.vm-nic-zone2.private_ip_address]
  }

  ############################################
  #####     health_probe                 #####
  ############################################

  probe {
    name                = "homepage"
    protocol            = "Http"
    host                = "www.sanvisolutions.xyz"
    path                = "/"
    interval            = "30"
    timeout             = "30"
    unhealthy_threshold = "3"

  }
  probe {
    name                = "movies"
    protocol            = "Http"
    host                = "www.sanvisolutions.xyz"
    path                = "/movies"
    interval            = "30"
    timeout             = "30"
    unhealthy_threshold = "3"
  }


  ############################################
  #####     Configuration                #####
  ############################################

  backend_http_settings {
    name                  = "homepage"
    cookie_based_affinity = "Disabled"
    path                  = "/index.nginx-debian.html"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
    probe_name            = "homepage"
  }

  backend_http_settings {
    name                  = "movies"
    cookie_based_affinity = "Disabled"
    path                  = "/movies/index.nginx-debian.html"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
    probe_name            = "movies"
  }
  # URL Path Map - Define Path based Routing    
  # url_path_map {
  #   name = "homepage"
  #   # default_redirect_configuration_name = "homepage"
  #   default_backend_http_settings_name = "homepage"
  #   default_backend_address_pool_name  = "homepage"
  #   # path_rule {
  #   #   name                       = "homepage-rule"
  #   #   paths                      = ["/*"]
  #   #   backend_address_pool_name  = "homepage"
  #   #   backend_http_settings_name = "homepage"
  #   # }
  #   path_rule {
  #     name                       = "movies"
  #     paths                      = ["/movies/*"]
  #     backend_address_pool_name  = "movies"
  #     backend_http_settings_name = "movies"
  #   }
  # }

  ############################################
  #####     http_listener                #####
  ############################################
  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "feip"
    frontend_port_name             = "agw-fe-port"
    protocol                       = "Http"
    host_names                     = ["www.sanvisolutions.xyz"]

  }
  http_listener {
    name                           = "naked-http-listener"
    frontend_ip_configuration_name = "feip"
    frontend_port_name             = "agw-fe-port"
    protocol                       = "Http"
    host_names                     = ["sanvisolutions.xyz"]
  }

  ############################################
  #####    routing_rule                  #####
  ############################################
  request_routing_rule {
    name                       = "WWW-HTTP"
    priority                   = 10
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "homepage"
    backend_http_settings_name = "homepage"

  }
  request_routing_rule {
    name                       = "NAKED-HTTP"
    priority                   = 20
    rule_type                  = "Basic"
    http_listener_name         = "naked-http-listener"
    backend_address_pool_name  = "homepage"
    backend_http_settings_name = "homepage"
  }

}

