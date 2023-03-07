resource "azurerm_virtual_network_peering" "hub-spoke" {
  name                      = "hub-to-spoke"
  resource_group_name       = azurerm_resource_group.hub-rg.name
  virtual_network_name      = azurerm_virtual_network.hub-rg-vnet.name
  remote_virtual_network_id = azurerm_virtual_network.spoke-rg-vnet.id
}

resource "azurerm_virtual_network_peering" "spoke-hub" {
  name                      = "spoke-to-hub"
  resource_group_name       = azurerm_resource_group.spoke-rg.name
  virtual_network_name      = azurerm_virtual_network.spoke-rg-vnet.name
  remote_virtual_network_id = azurerm_virtual_network.hub-rg-vnet.id
}
