# FireWall subnet
resource "azurerm_subnet" "FirewallSubnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.hub-rg.name
  virtual_network_name = azurerm_virtual_network.hub-rg-vnet.name
  address_prefixes     = ["10.30.20.0/24"]
}

resource "azurerm_public_ip" "hub-firewall-pip" {
  name                = "firewall-pip"
  location            = azurerm_resource_group.hub-rg.location
  resource_group_name = azurerm_resource_group.hub-rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall_policy" "example" {
  name                = "azfw-policy"
  resource_group_name = azurerm_resource_group.hub-rg.name
  location            = azurerm_resource_group.hub-rg.location
  sku                 = "Premium"
}

resource "azurerm_firewall" "example" {
  name                = "AzureFireWall"
  location            = azurerm_resource_group.hub-rg.location
  resource_group_name = azurerm_resource_group.hub-rg.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Premium"
  firewall_policy_id  = azurerm_firewall_policy.example.id

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.FirewallSubnet.id
    public_ip_address_id = azurerm_public_ip.hub-firewall-pip.id
  }
}

# route table 
resource "azurerm_route_table" "hub-firewall" {
  name                          = "hub-to-firewall"
  location                      = azurerm_resource_group.hub-rg.location
  resource_group_name           = azurerm_resource_group.hub-rg.name
  disable_bgp_route_propagation = false
  route {
    name                   = "hub-to-firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.example.ip_configuration[0].private_ip_address
  }

  tags = {
    environment = "test"
  }
}

# resource "azurerm_subnet_route_table_association" "rt-hubsubnet-association" {
#   count          = 1
#   subnet_id      = azurerm_subnet.hub-subnets[0].id
#   route_table_id = azurerm_route_table.hub-firewall.id
# }

resource "azurerm_route_table" "spoke-firewall" {
  name                          = "spoke-to-firewall"
  location                      = azurerm_resource_group.spoke-rg.location
  resource_group_name           = azurerm_resource_group.spoke-rg.name
  disable_bgp_route_propagation = false


  route {
    name                   = "spoke-to-firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.example.ip_configuration[0].private_ip_address
    # subnet_id              = ""
  }

  tags = {
    environment = "test"
  }
}
# Associate route_table to subnets 
resource "azurerm_subnet_route_table_association" "rt-spokesubnet-association" {
  count          = 1
  subnet_id      = azurerm_subnet.spoke-subnets[0].id
  route_table_id = azurerm_route_table.spoke-firewall.id
}

resource "azurerm_route_table" "db-firewall" {
  name                          = "db-to-firewall"
  location                      = azurerm_resource_group.db-rg.location
  resource_group_name           = azurerm_resource_group.db-rg.name
  disable_bgp_route_propagation = false


  route {
    name                   = "db-to-firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.example.ip_configuration[0].private_ip_address
    # subnet_id              = ""
  }

  tags = {
    environment = "test"
  }
}
# Associate route_table to subnets 
resource "azurerm_subnet_route_table_association" "rt-dbsubnet-association" {
  subnet_id      = azurerm_subnet.db-subnets.id
  route_table_id = azurerm_route_table.db-firewall.id
}

# firewall policy to allow/deny traffic to/from vnets

# Front-End-Servers:
#     Web-Ser1: 10.30.1.100
#     Web-Ser2: 10.30.1.101
#     Web-Ser3: 10.30.1.103

# Back-End-Servers:
#     Web-Ser1: 10.30.2.100
#     Web-Ser2: 10.30.2.101
#     Web-Ser3: 10.30.2.103

# db-End-Servers:
#     Web-Ser1: 10.30.3.100
#     Web-Ser2: 10.30.3.101
#     Web-Ser3: 10.30.3.103

resource "azurerm_firewall_policy_rule_collection_group" "example" {
  name               = "spoke-fwpolicy-rcg"
  firewall_policy_id = azurerm_firewall_policy.example.id
  priority           = 100
  application_rule_collection {
    name     = "spoke_app_rule_collection-allow-traffic"
    priority = 2000
    action   = "Allow"
    rule {
      name = "Allow-All-Websites"
      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["172.16.0.0/16"]
      destination_fqdns = ["*"]
    }
  }
  application_rule_collection {
    name     = "spoke_app_rule_collection-Deny-traffic"
    priority = 1800
    action   = "Deny"
    rule {
      name = "Deny-specific-Websites"
      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses = ["172.16.0.0/16"]
      # destination_fqdns = ["www.google.com", "www.amazon.com", "www.tinder.com", "www.youtube.com"]
      web_categories = ["Shopping", "SocialNetworking", "Violence", "Sports"]
    }
  }
  network_rule_collection {
    name     = "spoke_nw_rc_Allow_traffic"
    priority = 1000
    action   = "Allow"
    rule {
      name                  = "allow-web-app"
      protocols             = ["TCP", "UDP"]
      source_addresses      = ["10.30.1.0/24"]
      destination_addresses = ["10.30.2.0/24"]
      destination_ports     = ["8080"]
    }
    rule {
      name                  = "allow-app-db"
      protocols             = ["TCP", "UDP"]
      source_addresses      = ["10.30.2.0/24"]
      destination_addresses = ["10.30.3.0/24"]
      destination_ports     = ["1433"]
    }
  }

  nat_rule_collection {
    name     = "spoke_nat_rule_collection1"
    priority = 300
    action   = "Dnat"
    rule {
      name                = "nat_spoke_rule1"
      protocols           = ["TCP", "UDP"]
      source_addresses    = ["70.79.100.125"]
      destination_address = "40.76.75.245"
      destination_ports   = ["50000"]
      translated_address  = "172.16.1.100"
      translated_port     = "3389"
    }
    rule {
      name                = "nat_db_rule2"
      protocols           = ["TCP", "UDP"]
      source_addresses    = ["70.79.100.125"]
      destination_address = "40.76.75.245"
      destination_ports   = ["50001"]
      translated_address  = "192.168.1.100"
      translated_port     = "3389"
    }
  }
}

