# Gateway subnet
# resource "azurerm_subnet" "GatewaySubnet" {
#   name                 = "GatewaySubnet"
#   resource_group_name  = azurerm_resource_group.hub-rg.name
#   virtual_network_name = azurerm_virtual_network.hub-rg-vnet.name
#   address_prefixes     = ["10.30.10.0/24"]
# }

# resource "azurerm_public_ip" "hub-vng-pip" {
#   name                = "test"
#   location            = azurerm_resource_group.hub-rg.location
#   resource_group_name = azurerm_resource_group.hub-rg.name

#   allocation_method = "Dynamic"
# }

# resource "azurerm_network_interface" "hub-nic-vng" {
#   name                = "vng1"
#   location            = azurerm_resource_group.hub-rg.location
#   resource_group_name = azurerm_resource_group.hub-rg.name

#   ip_configuration {
#     name                          = "vng1"
#     subnet_id                     = azurerm_subnet.GatewaySubnet.id
#     private_ip_address_allocation = "Static"
#     private_ip_address            = "10.30.10.100"
#     public_ip_address_id          = azurerm_public_ip.hub-vng-pip.id
#   }
# }

# resource "azurerm_virtual_network_gateway" "example" {
#   name                = "hub-VNG1"
#   location            = azurerm_resource_group.hub-rg.location
#   resource_group_name = azurerm_resource_group.hub-rg.name

#   type     = "Vpn"
#   vpn_type = "RouteBased"

#   active_active = false
#   enable_bgp    = false
#   sku           = "Basic"
#   ip_configuration {
#     name                          = "vnetGatewayConfig"
#     public_ip_address_id          = azurerm_public_ip.hub-vng-pip.id
#     private_ip_address_allocation = "Dynamic"
#     subnet_id                     = azurerm_subnet.GatewaySubnet.id
#   }
# }
