# Resource-Gropu
resource "azurerm_resource_group" "hub-rg" {
  name     = "hub-rg"
  location = "East US"
}

resource "azurerm_virtual_network" "hub-rg-vnet" {
  name                = "hub-rg-vnet"
  resource_group_name = azurerm_resource_group.hub-rg.name
  location            = azurerm_resource_group.hub-rg.location
  address_space       = ["10.30.0.0/16"]
}

resource "azurerm_subnet" "hub-subnets" {
  count                = length(var.hub_subnet_names)
  name                 = "${var.hub_subnet_names[count.index]}-subnets"
  resource_group_name  = azurerm_resource_group.hub-rg.name
  virtual_network_name = azurerm_virtual_network.hub-rg-vnet.name
  address_prefixes     = [local.hub_subnet_map[var.hub_subnet_names[count.index]]]
}


resource "azurerm_network_security_group" "hub-nsg" {
  name                = "HubNetworkSecurityGroup"
  location            = azurerm_resource_group.hub-rg.location
  resource_group_name = azurerm_resource_group.hub-rg.name

  security_rule {
    name                       = "allow_all_traffic"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags = {
    environment = "test"
  }
}
# resource "azurerm_public_ip" "hub-pubip-lin" {
#   count               = length(var.hub_subnet_names)
#   name                = "${var.hub_subnet_names[count.index]}-pip"
#   location            = azurerm_resource_group.hub-rg.location
#   resource_group_name = azurerm_resource_group.hub-rg.name
#   allocation_method   = "Static"
# }
resource "azurerm_public_ip" "hub-pubip-win" {
  count               = length(var.hub_subnet_names)
  name                = "${var.hub_subnet_names[count.index]}-pip"
  location            = azurerm_resource_group.hub-rg.location
  resource_group_name = azurerm_resource_group.hub-rg.name
  allocation_method   = "Dynamic"
}

# resource "azurerm_network_interface" "hub-nic" {
#   count               = length(var.hub_subnet_names)
#   name                = var.hub_subnet_names[count.index]
#   location            = azurerm_resource_group.hub-rg.location
#   resource_group_name = azurerm_resource_group.hub-rg.name

#   ip_configuration {
#     name                          = "${var.hub_subnet_names[count.index]}hub-nic"
#     subnet_id                     = azurerm_subnet.hub-subnets[count.index].id
#     private_ip_address_allocation = "Static"
#     private_ip_address            = "10.30.1.100"
#     public_ip_address_id          = azurerm_public_ip.hub-pubip-lin[count.index].id
#   }
# }

resource "azurerm_network_interface" "hub-nic-win" {
  count               = length(var.hub_subnet_names)
  name                = "${var.hub_subnet_names[count.index]}HubNICWin"
  location            = azurerm_resource_group.hub-rg.location
  resource_group_name = azurerm_resource_group.hub-rg.name

  ip_configuration {
    name                          = "${var.hub_subnet_names[count.index]}hub-nic-win"
    subnet_id                     = azurerm_subnet.hub-subnets[count.index].id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.30.1.200"
    public_ip_address_id          = azurerm_public_ip.hub-pubip-win[count.index].id
  }
}


# resource "azurerm_virtual_machine" "LinuxVmHub" {
#   count                 = 1
#   name                  = "UbuntuMachine"
#   location              = azurerm_resource_group.hub-rg.location
#   resource_group_name   = azurerm_resource_group.hub-rg.name
#   network_interface_ids = [azurerm_network_interface.hub-nic[0].id]
#   vm_size               = "Standard_DS1_v2"


#   # Uncomment this line to delete the OS disk automatically when deleting the VM
#   delete_os_disk_on_termination = true

#   # Uncomment this line to delete the data disks automatically when deleting the VM
#   delete_data_disks_on_termination = true

#   storage_image_reference {
#     publisher = "Canonical"
#     offer     = "UbuntuServer"
#     sku       = "16.04-LTS"
#     version   = "latest"
#   }
#   storage_os_disk {
#     name              = "myosdisk1"
#     caching           = "ReadWrite"
#     create_option     = "FromImage"
#     managed_disk_type = "Standard_LRS"
#   }
#   os_profile {
#     computer_name  = "hostname"
#     admin_username = "testadmin"
#     admin_password = "Password1234!"
#   }
#   os_profile_linux_config {
#     disable_password_authentication = false
#   }
#   tags = {
#     environment = "test"
#   }
# }

# azurerm_virtual_machine for WindowVm
resource "azurerm_virtual_machine" "WindowsVmHub" {
  count                 = 1
  name                  = "WindowsMachine"
  location              = azurerm_resource_group.hub-rg.location
  resource_group_name   = azurerm_resource_group.hub-rg.name
  network_interface_ids = [azurerm_network_interface.hub-nic-win[0].id]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2012-R2-Datacenter"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk2"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_windows_config {
    provision_vm_agent = true
  }
  tags = {
    environment = "test"
  }
}
