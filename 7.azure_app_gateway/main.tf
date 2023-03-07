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
resource "azurerm_resource_group" "agw-rg" {
  name     = "agw-rg"
  location = "East US"
}

resource "azurerm_virtual_network" "agw-rg-vnet" {
  name                = "agw-rg-vnet"
  resource_group_name = azurerm_resource_group.agw-rg.name
  location            = azurerm_resource_group.agw-rg.location
  address_space       = ["10.30.0.0/16"]
}

# for virtual machines
resource "azurerm_subnet" "vm-subnets" {
  name                 = "vm-subnets"
  resource_group_name  = azurerm_resource_group.agw-rg.name
  virtual_network_name = azurerm_virtual_network.agw-rg-vnet.name
  address_prefixes     = ["10.30.2.0/24"]
}


resource "azurerm_network_security_group" "agw-nsg" {
  name                = "agwNetworkSecurityGroup"
  location            = azurerm_resource_group.agw-rg.location
  resource_group_name = azurerm_resource_group.agw-rg.name

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
#  associate nsg to agw subnets
resource "azurerm_subnet_network_security_group_association" "agw-nsg" {
  subnet_id                 = azurerm_subnet.agw-subnets.id
  network_security_group_id = azurerm_network_security_group.agw-nsg.id
}

#  associate nsg to vm subnets
resource "azurerm_subnet_network_security_group_association" "vm-nsg" {
  subnet_id                 = azurerm_subnet.vm-subnets.id
  network_security_group_id = azurerm_network_security_group.agw-nsg.id
}


resource "azurerm_public_ip" "agw-pubip-zone1" {
  name                = "agw-pip1"
  location            = azurerm_resource_group.agw-rg.location
  resource_group_name = azurerm_resource_group.agw-rg.name
  allocation_method   = "Static"
  zones               = ["1"]
  sku                 = "Standard"
}

resource "azurerm_public_ip" "vm-pubip-zone1" {
  name                = "vm-pip1"
  location            = azurerm_resource_group.agw-rg.location
  resource_group_name = azurerm_resource_group.agw-rg.name
  allocation_method   = "Static"
  zones               = ["1"]
  sku                 = "Standard"
}
resource "azurerm_public_ip" "vm-pubip-zone2" {
  name                = "vm-pip2"
  location            = azurerm_resource_group.agw-rg.location
  resource_group_name = azurerm_resource_group.agw-rg.name
  allocation_method   = "Static"
  zones               = ["1"]
  sku                 = "Standard"
}
#  network interface to agw
# resource "azurerm_network_interface" "agw-nic-zone1" {
#   name                = "agw-nic1"
#   location            = azurerm_resource_group.agw-rg.location
#   resource_group_name = azurerm_resource_group.agw-rg.name

#   ip_configuration {
#     name                          = "agw-nic1"
#     subnet_id                     = azurerm_subnet.agw-subnets.id
#     private_ip_address_allocation = "Static"
#     private_ip_address            = "10.30.1.100"
#     public_ip_address_id          = azurerm_public_ip.agw-pubip-zone1.id
#   }
# }

#  network interface to vm_zone1
resource "azurerm_network_interface" "vm-nic-zone1" {
  name                = "vm-nic1"
  location            = azurerm_resource_group.agw-rg.location
  resource_group_name = azurerm_resource_group.agw-rg.name

  ip_configuration {
    name                          = "vm-nic1"
    subnet_id                     = azurerm_subnet.vm-subnets.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.30.2.100"
    public_ip_address_id          = azurerm_public_ip.vm-pubip-zone1.id
  }
}

resource "azurerm_network_interface" "vm-nic-zone2" {
  name                = "vm-nic2"
  location            = azurerm_resource_group.agw-rg.location
  resource_group_name = azurerm_resource_group.agw-rg.name

  ip_configuration {
    name                          = "vm-nic2"
    subnet_id                     = azurerm_subnet.vm-subnets.id // 10.30.1.0/24
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.30.2.200"

    public_ip_address_id = azurerm_public_ip.vm-pubip-zone2.id
  }
}

resource "azurerm_virtual_machine" "Homepage" {
  name                  = "Homepage"
  location              = azurerm_resource_group.agw-rg.location
  resource_group_name   = azurerm_resource_group.agw-rg.name
  network_interface_ids = [azurerm_network_interface.vm-nic-zone1.id]
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
    azurerm_public_ip.vm-pubip-zone1
  ]
}


resource "azurerm_virtual_machine" "movies" {
  name                  = "Movies1"
  location              = azurerm_resource_group.agw-rg.location
  resource_group_name   = azurerm_resource_group.agw-rg.name
  network_interface_ids = [azurerm_network_interface.vm-nic-zone2.id]
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
    azurerm_public_ip.vm-pubip-zone2
  ]
}


resource "null_resource" "cloud-init1" {

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get -y install nginx stress unzip jq net-tools",
      "sudo service nginx restart",
      "sudo systemctl enable nginx",
      "sudo sh -c 'echo \"<h1>$(cat /etc/hostname)</h1><h2>Homepage</h2>\" > /var/www/html/index.nginx-debian.html'",
    ]

    connection {
      type     = "ssh"
      user     = "testadmin"
      password = "Password1234!"
      host     = azurerm_public_ip.vm-pubip-zone1.ip_address
      timeout  = "120s"
    }
  }
  depends_on = [azurerm_virtual_machine.Homepage]
}


resource "null_resource" "cloud-init2" {

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get -y install nginx stress unzip jq net-tools",
      "sudo service nginx restart",
      "sudo systemctl enable nginx",
      "sudo sh -c 'echo \"<h1>$(cat /etc/hostname)</h1><h2>Movies</h2>\" > /var/www/html/index.nginx-debian.html'",
      "sudo mkdir /var/www/html/movies && sudo mv /var/www/html/index.nginx-debian.html /var/www/html/movies"
    ]

    connection {
      type     = "ssh"
      user     = "testadmin"
      password = "Password1234!"
      host     = azurerm_public_ip.vm-pubip-zone2.ip_address
      timeout  = "60s"
    }
  }
  depends_on = [azurerm_virtual_machine.movies]
}


