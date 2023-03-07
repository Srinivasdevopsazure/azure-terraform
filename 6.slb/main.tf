#requirement
# configure 3 vm's in different zones and install custom data inside it

# 1. rg 
# 2. vnet
# 3. subnets
# 4. nsg - sg
# 5. public ip
# 6. network interface
# 7. vm's

# Resource-Gropu
resource "azurerm_resource_group" "slb-rg" {
  name     = "slb-rg"
  location = "East US"
}

resource "azurerm_virtual_network" "slb-rg-vnet" {
  name                = "slb-rg-vnet"
  resource_group_name = azurerm_resource_group.slb-rg.name
  location            = azurerm_resource_group.slb-rg.location
  address_space       = ["10.30.0.0/16"]
}

resource "azurerm_subnet" "slb-subnets" {
  name                 = "slb-subnets"
  resource_group_name  = azurerm_resource_group.slb-rg.name
  virtual_network_name = azurerm_virtual_network.slb-rg-vnet.name
  address_prefixes     = ["10.30.1.0/24"]
}


resource "azurerm_network_security_group" "slb-nsg" {
  name                = "slbNetworkSecurityGroup"
  location            = azurerm_resource_group.slb-rg.location
  resource_group_name = azurerm_resource_group.slb-rg.name

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

resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.slb-subnets.id
  network_security_group_id = azurerm_network_security_group.slb-nsg.id
}

resource "azurerm_public_ip" "slb-pubip-zone1" {
  name                = "slb-pip1"
  location            = azurerm_resource_group.slb-rg.location
  resource_group_name = azurerm_resource_group.slb-rg.name
  allocation_method   = "Static"
  zones               = ["1"]
  sku                 = "Standard"
}

resource "azurerm_public_ip" "slb-pubip-zone2" {
  name                = "slb-pip2"
  location            = azurerm_resource_group.slb-rg.location
  resource_group_name = azurerm_resource_group.slb-rg.name
  allocation_method   = "Static"
  zones               = ["2"]
  sku                 = "Standard"
}
# resource "azurerm_public_ip" "slb-pubip-zone3" {
#   name                = "slb-pip3"
#   location            = azurerm_resource_group.slb-rg.location
#   resource_group_name = azurerm_resource_group.slb-rg.name
#   allocation_method   = "Static"
#   zones               = ["3"]
#   sku                 = "Standard"
# }

resource "azurerm_network_interface" "slb-nic-zone1" {
  name                = "slb-nic1"
  location            = azurerm_resource_group.slb-rg.location
  resource_group_name = azurerm_resource_group.slb-rg.name

  ip_configuration {
    name                          = "slb-nic1"
    subnet_id                     = azurerm_subnet.slb-subnets.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.30.1.100"
    public_ip_address_id          = azurerm_public_ip.slb-pubip-zone1.id
  }
}

resource "azurerm_network_interface" "slb-nic-zone2" {
  name                = "slb-nic2"
  location            = azurerm_resource_group.slb-rg.location
  resource_group_name = azurerm_resource_group.slb-rg.name

  ip_configuration {
    name                          = "slb-nic2"
    subnet_id                     = azurerm_subnet.slb-subnets.id // 10.30.1.0/24
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.30.1.200"
    public_ip_address_id          = azurerm_public_ip.slb-pubip-zone2.id
  }
}

# resource "azurerm_network_interface" "slb-nic-zone3" {
#   name                = "slb-nic3"
#   location            = azurerm_resource_group.slb-rg.location
#   resource_group_name = azurerm_resource_group.slb-rg.name

#   ip_configuration {
#     name                          = "slb-nic3"
#     subnet_id                     = azurerm_subnet.slb-subnets.id
#     private_ip_address_allocation = "Static"
#     private_ip_address            = "10.30.1.201"
#     public_ip_address_id          = azurerm_public_ip.slb-pubip-zone3.id
#   }

# }

resource "azurerm_virtual_machine" "vmZone1" {
  name                  = "vmZone1"
  location              = azurerm_resource_group.slb-rg.location
  resource_group_name   = azurerm_resource_group.slb-rg.name
  network_interface_ids = [azurerm_network_interface.slb-nic-zone1.id]
  vm_size               = "Standard_DS1_v2"
  zones                 = ["1"]


  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "test"
  }
  depends_on = [
    azurerm_public_ip.slb-pubip-zone1
  ]
}


resource "azurerm_virtual_machine" "vmZone2" {
  name                  = "vmZone2"
  location              = azurerm_resource_group.slb-rg.location
  resource_group_name   = azurerm_resource_group.slb-rg.name
  network_interface_ids = [azurerm_network_interface.slb-nic-zone2.id]
  vm_size               = "Standard_DS1_v2"
  zones                 = ["2"]
  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
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
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "test"
  }
  depends_on = [
    azurerm_public_ip.slb-pubip-zone2
  ]
}

# resource "azurerm_virtual_machine" "vmZone3" {
#   name                  = "vmZone3"
#   location              = azurerm_resource_group.slb-rg.location
#   resource_group_name   = azurerm_resource_group.slb-rg.name
#   network_interface_ids = [azurerm_network_interface.slb-nic-zone3.id]
#   vm_size               = "Standard_DS1_v2"
#   zones                 = ["3"]
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
#     name              = "myosdisk3"
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


resource "null_resource" "cloud-init1" {

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get -y install nginx stress unzip jq net-tools",
      "sudo service nginx restart",
      "sudo systemctl enable nginx",
      "sudo sh -c 'echo \"<h1>$(cat /etc/hostname)</h1><h2>host1</h2>\" > /var/www/html/index.nginx-debian.html'",
    ]

    connection {
      type     = "ssh"
      user     = "testadmin"
      password = "Password1234!"
      host     = azurerm_public_ip.slb-pubip-zone1.ip_address
      timeout  = "120s"
    }
  }
  depends_on = [azurerm_virtual_machine.vmZone1]
}


resource "null_resource" "cloud-init2" {

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get -y install nginx stress unzip jq net-tools",
      "sudo service nginx restart",
      "sudo systemctl enable nginx",
      "sudo sh -c 'echo \"<h1>$(cat /etc/hostname)</h1><h2>host2</h2>\" > /var/www/html/index.nginx-debian.html'",
    ]

    connection {
      type     = "ssh"
      user     = "testadmin"
      password = "Password1234!"
      host     = azurerm_public_ip.slb-pubip-zone2.ip_address
      timeout  = "120s"
    }
  }
  depends_on = [azurerm_virtual_machine.vmZone2]
}


# resource "null_resource" "cloud-init3" {

#   provisioner "remote-exec" {
#     inline = [
#       "sudo apt-get update",
#       "sudo apt-get -y install nginx stress unzip jq net-tools",
#       "sudo service nginx restart",
#       "sudo systemctl enable nginx",
#       "sudo sh -c 'echo \"<h1>$(cat /etc/hostname)</h1><h2>host3</h2>\" > /var/www/html/index.nginx-debian.html'",
#     ]

#     connection {
#       type     = "ssh"
#       user     = "testadmin"
#       password = "Password1234!"
#       host     = azurerm_public_ip.slb-pubip-zone3.ip_address
#       timeout  = "120s"
#     }
#   }
#   depends_on = [azurerm_virtual_machine.vmZone3, null_resource.cloud-init1, null_resource.cloud-init2]
# }

