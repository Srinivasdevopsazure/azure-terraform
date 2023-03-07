# requirement
/*
HUB-RG:
  - HUB-RG-VNET -> 10.30.0.0/16
  - region      -> East Us
    - subnet01            -> 10.30.1.0/24
      -> VM's                -> linuxVM01 -> 10.30.1.100
                             -> winVM     -> 10.30.1.200
    - gateway subnet      -> 10.30.10.0/24
    - AzureFirewallSubnet -> 10.30.20.0/24

spoke-RG:
  - vNET       -> 172.16.0.0/16
  - region      -> East Us
    - subnet      -> 172.16.1.0/24
      - VM           -> 172.16.1.100

BRAVO-RG:
  - vNET       -> 192.168.0.0/16
  - region      -> West Us
    - subnet      -> 192.168.1.0/24
      - VM           -> 192.168.1.100
*/


locals {
  hub_subnet_map = {
    "HubLinuxVm" = "10.30.1.0/24"
  }
  spoke_subnet_map = {
    "spokeLinuxVm" = "172.16.1.0/24"
  }
  bravo_subnet_map = {
    "BravoLinuxVm" = "192.168.1.0/24"
  }
}

# Create a resource group

resource "azurerm_resource_group" "spoke-rg" {
  name     = "spoke-rg"
  location = "East US"
}

# resource "azurerm_resource_group" "bravo-rg" {
#   name     = "bravo-rg"
#   location = "East US 2"
# }

# Create a virtual network within the resource group


resource "azurerm_virtual_network" "spoke-rg-vnet" {
  name                = "spoke-rg-vnet"
  resource_group_name = azurerm_resource_group.spoke-rg.name
  location            = azurerm_resource_group.spoke-rg.location
  address_space       = ["172.16.0.0/16"]
}

# resource "azurerm_virtual_network" "bravo-rg-vnet" {
#   name                = "bravo-rg-vnet"
#   resource_group_name = azurerm_resource_group.bravo-rg.name
#   location            = azurerm_resource_group.bravo-rg.location
#   address_space       = ["192.168.0.0/16"]
# }

# azurerm_subnet


resource "azurerm_subnet" "spoke-subnets" {
  count                = length(var.spoke_subnet_names)
  name                 = var.spoke_subnet_names[count.index]
  resource_group_name  = azurerm_resource_group.spoke-rg.name
  virtual_network_name = azurerm_virtual_network.spoke-rg-vnet.name
  address_prefixes     = [local.spoke_subnet_map[var.spoke_subnet_names[count.index]]]
}

# resource "azurerm_subnet" "bravo-subnets" {
#   count                = length(var.bravo_subnet_names)
#   name                 = var.bravo_subnet_names[count.index]
#   resource_group_name  = azurerm_resource_group.bravo-rg.name
#   virtual_network_name = azurerm_virtual_network.bravo-rg-vnet.name
#   address_prefixes     = [local.bravo_subnet_map[var.bravo_subnet_names[count.index]]]
# }

# azurerm_network_security_group


resource "azurerm_network_security_group" "spoke-nsg" {
  name                = "spokeNetworkSecurityGroup"
  location            = azurerm_resource_group.spoke-rg.location
  resource_group_name = azurerm_resource_group.spoke-rg.name

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
# resource "azurerm_network_security_group" "bravo-nsg" {
#   name                = "BravoNetworkSecurityGroup"
#   location            = azurerm_resource_group.bravo-rg.location
#   resource_group_name = azurerm_resource_group.bravo-rg.name

#   security_rule {
#     name                       = "allow_all_traffic"
#     priority                   = 100
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "*"
#     source_port_range          = "*"
#     destination_port_range     = "*"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }
#   tags = {
#     environment = "test"
#   }
# }

# # azurerm_public_ip_address


resource "azurerm_public_ip" "spoke-pubip" {
  name                = "spoke-public-ip-address"
  location            = azurerm_resource_group.spoke-rg.location
  resource_group_name = azurerm_resource_group.spoke-rg.name
  allocation_method   = "Static"
}
# resource "azurerm_public_ip" "bravo-pubip" {
#   name                = "bravo-public-ip-address"
#   location            = azurerm_resource_group.bravo-rg.location
#   resource_group_name = azurerm_resource_group.bravo-rg.name
#   allocation_method   = "Static"
# }

# azurerm_network_interface

resource "azurerm_network_interface" "spoke-nic" {
  count               = length(var.spoke_subnet_names)
  name                = "${var.spoke_subnet_names[count.index]}spokeNIC"
  location            = azurerm_resource_group.spoke-rg.location
  resource_group_name = azurerm_resource_group.spoke-rg.name

  ip_configuration {
    name                          = "${var.spoke_subnet_names[count.index]}spoke-NIC"
    subnet_id                     = azurerm_subnet.spoke-subnets[count.index].id
    private_ip_address_allocation = "Static"
    private_ip_address            = "172.16.1.100"
    public_ip_address_id          = azurerm_public_ip.spoke-pubip.id
  }
}

# resource "azurerm_network_interface" "bravo-nic" {
#   count               = length(var.bravo_subnet_names)
#   name                = "${var.bravo_subnet_names[count.index]}BravoNIC"
#   location            = azurerm_resource_group.bravo-rg.location
#   resource_group_name = azurerm_resource_group.bravo-rg.name

#   ip_configuration {
#     name                          = "${var.bravo_subnet_names[count.index]}Bravo-NIC"
#     subnet_id                     = azurerm_subnet.bravo-subnets[count.index].id
#     private_ip_address_allocation = "Static"
#     private_ip_address            = "192.168.1.100"
#     public_ip_address_id          = azurerm_public_ip.bravo-pubip.id
#   }
# }

# azurerm_virtual_machine for LinuxVm for hub-rg

# azurerm_virtual_machine for LinuxVm for spoke-rg
# resource "azurerm_virtual_machine" "LinuxVmspoke" {
#   count                 = 1
#   name                  = "UbuntuMachinespoke"
#   location              = azurerm_resource_group.spoke-rg.location
#   resource_group_name   = azurerm_resource_group.spoke-rg.name
#   network_interface_ids = [azurerm_network_interface.spoke-nic[0].id]
#   vm_size               = "Standard_DS1_v2"


#   # Uncomment this line to delete the OS disk automatically when deleting the VM
#   delete_os_disk_on_termination = true

#   # Uncomment this line to delete the data disks automatically when deleting the VM
#   delete_data_disks_on_termination = true

#   storage_image_reference {
#     publisher = "Canonical"
#     offer     = "UbuntuServer"
#     sku       = "18.04-LTS"
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
resource "azurerm_virtual_machine" "WindowsVmAlpha" {
  count                 = 1
  name                  = "WindowsMachine"
  location              = azurerm_resource_group.spoke-rg.location
  resource_group_name   = azurerm_resource_group.spoke-rg.name
  network_interface_ids = [azurerm_network_interface.spoke-nic[0].id]
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
