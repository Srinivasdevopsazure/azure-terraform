# 1. create load balancer
# 2. front end config(assign pip)
# 3. backend pools ( assign vms)
# 4. inbound load balancing rules( bydefault outbound disabled for security reasons)

# 1. public_ip
# 2. load_balancer with frontend_ip_configuration
# 3. backend_address_pool
# 4. backend_address_pool address 
# 5. load balancer probe 
# 6. load balancer rule 


resource "azurerm_public_ip" "slb-pip" {
  name                = "slb-pip"
  location            = azurerm_resource_group.slb-rg.location
  resource_group_name = azurerm_resource_group.slb-rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "slb-lb" {
  name                = "slb-lb"
  location            = azurerm_resource_group.slb-rg.location
  resource_group_name = azurerm_resource_group.slb-rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "slb-pip"
    public_ip_address_id = azurerm_public_ip.slb-pip.id
  }
  depends_on = [
    azurerm_public_ip.slb-pip
  ]
}

resource "azurerm_lb_backend_address_pool" "slb-be-pool" {
  loadbalancer_id = azurerm_lb.slb-lb.id
  name            = "SLB-BackEndAddressPool"
  depends_on = [
    azurerm_lb.slb-lb
  ]
}

resource "azurerm_lb_backend_address_pool_address" "add-vm1" {
  name                    = "slb-be-pool-addr-vm1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.slb-be-pool.id
  virtual_network_id      = azurerm_virtual_network.slb-rg-vnet.id
  ip_address              = azurerm_network_interface.slb-nic-zone1.private_ip_address
  depends_on = [
    azurerm_lb_backend_address_pool.slb-be-pool
  ]
}
resource "azurerm_lb_backend_address_pool_address" "add-vm2" {
  name                    = "slb-be-pool-addr-vm2"
  backend_address_pool_id = azurerm_lb_backend_address_pool.slb-be-pool.id
  virtual_network_id      = azurerm_virtual_network.slb-rg-vnet.id
  ip_address              = azurerm_network_interface.slb-nic-zone2.private_ip_address
  depends_on = [
    azurerm_lb_backend_address_pool.slb-be-pool
  ]
}
# resource "azurerm_lb_backend_address_pool_address" "add-vm3" {
#   name                    = "slb-be-pool-addr-vm1"
#   backend_address_pool_id = azurerm_lb_backend_address_pool.slb-be-pool.id
#   virtual_network_id      = azurerm_virtual_network.slb-rg-vnet.id
#   ip_address              = azurerm_network_interface.slb-nic-zone3.private_ip_address
#   depends_on = [
#     azurerm_lb_backend_address_pool.slb-be-pool
#   ]
# }

resource "azurerm_lb_probe" "healthProbeA" {
  loadbalancer_id = azurerm_lb.slb-lb.id
  name            = "healthProbeA"
  port            = 80
  depends_on = [
    azurerm_lb.slb-lb
  ]
}

resource "azurerm_lb_rule" "slb-rule" {
  loadbalancer_id                = azurerm_lb.slb-lb.id
  name                           = "SLB-Rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "slb-pip"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.slb-be-pool.id]
  probe_id                       = azurerm_lb_probe.healthProbeA.id

  depends_on = [
    azurerm_lb.slb-lb, azurerm_lb_probe.healthProbeA
  ]

}

resource "azurerm_lb_nat_rule" "example" {
  resource_group_name            = azurerm_resource_group.slb-rg.name
  loadbalancer_id                = azurerm_lb.slb-lb.id
  name                           = "Vm1Access"
  protocol                       = "Tcp"
  frontend_port                  = 50000
  backend_port                   = 22
  frontend_ip_configuration_name = "slb-pip"
}

resource "azurerm_network_interface_nat_rule_association" "example" {
  network_interface_id  = azurerm_network_interface.slb-nic-zone1.id
  ip_configuration_name = "slb-nic1"
  nat_rule_id           = azurerm_lb_nat_rule.example.id
}

resource "azurerm_lb_nat_rule" "example2" {
  resource_group_name            = azurerm_resource_group.slb-rg.name
  loadbalancer_id                = azurerm_lb.slb-lb.id
  name                           = "Vm2Access"
  protocol                       = "Tcp"
  frontend_port                  = 50001
  backend_port                   = 22
  frontend_ip_configuration_name = "slb-pip"
}

resource "azurerm_network_interface_nat_rule_association" "example2" {
  network_interface_id  = azurerm_network_interface.slb-nic-zone2.id
  ip_configuration_name = "slb-nic2"
  nat_rule_id           = azurerm_lb_nat_rule.example2.id
}

