# 1. An Azure subscription
# 2. A Resource Group created in the Azure subscription
# 3. A Virtual Network created in the Resource Group
# 4. Subnets created within the Virtual Network
# 5. A Network Security Group created in the Resource Group
# 6. A Public IP address created in the Resource Group(optional)
# 7. Network Interfaces (NICs) created in the Resource Group
# 8. A Storage Account for the virtual machine's disk
# 9. A Virtual Machine Image for the operating system
#    These resources must be created before the virtual machine resource in the Terraform code can be created.

# Create a resource group

resource "azurerm_resource_group" "nsg-rg" {
  name     = "nsg-rg"
  location = "East US"
}

resource "azurerm_network_security_group" "subnet_nsg" {
  name                = "subnet_nsg"
  location            = azurerm_resource_group.nsg-rg.location
  resource_group_name = azurerm_resource_group.nsg-rg.name
  security_rule {
    name                       = "allowICMPAnyInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "10.30.0.0/16"
  }
  security_rule {
    name                       = "allow_ssh"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "10.30.0.0/16"
  }

}
resource "azurerm_subnet_network_security_group_association" "nsg-sub1-asssociation" {
  subnet_id                 = azurerm_subnet.nsg-subnet1.id
  network_security_group_id = azurerm_network_security_group.subnet_nsg.id
}
resource "azurerm_subnet_network_security_group_association" "nsg-sub2-asssociation" {
  subnet_id                 = azurerm_subnet.nsg-subnet2.id
  network_security_group_id = azurerm_network_security_group.subnet_nsg.id
}
resource "azurerm_subnet_network_security_group_association" "nsg-sub3-asssociation" {
  subnet_id                 = azurerm_subnet.nsg-subnet3.id
  network_security_group_id = azurerm_network_security_group.subnet_nsg.id
}

# webvm_nsg
resource "azurerm_network_security_group" "webvm_nsg" {
  name                = "webvm_nsg"
  location            = azurerm_resource_group.nsg-rg.location
  resource_group_name = azurerm_resource_group.nsg-rg.name
  security_rule {
    name                       = "allowHttpHttpsToWebServers"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["80", "443"]
    source_address_prefix      = "*"
    destination_address_prefix = "10.30.1.0/24"
  }
  security_rule {
    name                       = "allowICMPAnyInbound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "10.30.0.0/16"
  }
  security_rule {
    name                       = "allow_ssh"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "10.30.0.0/16"
  }
  security_rule {
    name                       = "allow_WEB-APP"
    priority                   = 120
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "10.30.1.0/24"
    destination_address_prefix = "10.30.2.0/24"
  }

}

# appvm_nsg
resource "azurerm_network_security_group" "appvm_nsg" {
  name                = "appvm_nsg"
  location            = azurerm_resource_group.nsg-rg.location
  resource_group_name = azurerm_resource_group.nsg-rg.name
  security_rule {
    name                       = "Allow-WEB-APP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "10.30.1.0/24"
    destination_address_prefix = "10.30.2.0/24"
  }
  security_rule {
    name                       = "allowICMPAnyInbound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "10.30.2.0/24"
  }
  security_rule {
    name                       = "allow_ssh"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "10.30.2.0/24"
  }
}


# dbvm_nsg
resource "azurerm_network_security_group" "dbvm_nsg" {
  name                = "dbvm_nsg"
  location            = azurerm_resource_group.nsg-rg.location
  resource_group_name = azurerm_resource_group.nsg-rg.name
  security_rule {
    name                       = "allow_ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

# Virtual Network

resource "azurerm_virtual_network" "nsg-vnet" {
  name                = "nsg-vnet"
  address_space       = ["10.30.0.0/16"]
  location            = azurerm_resource_group.nsg-rg.location
  resource_group_name = azurerm_resource_group.nsg-rg.name
  tags = {
    environment = "test"
  }
}

# subnets
resource "azurerm_subnet" "nsg-subnet1" {
  name                 = "nsg-subnet1"
  address_prefixes     = ["10.30.1.0/24"]
  resource_group_name  = azurerm_resource_group.nsg-rg.name
  virtual_network_name = azurerm_virtual_network.nsg-vnet.name
}
resource "azurerm_subnet" "nsg-subnet2" {
  name                 = "nsg-subnet2"
  address_prefixes     = ["10.30.2.0/24"]
  resource_group_name  = azurerm_resource_group.nsg-rg.name
  virtual_network_name = azurerm_virtual_network.nsg-vnet.name
}
resource "azurerm_subnet" "nsg-subnet3" {
  name                 = "nsg-subnet3"
  address_prefixes     = ["10.30.3.0/24"]
  resource_group_name  = azurerm_resource_group.nsg-rg.name
  virtual_network_name = azurerm_virtual_network.nsg-vnet.name
}

# public_ip webvm

resource "azurerm_public_ip" "web-nsg-pip" {
  name                = "web-nsg-pip"
  location            = azurerm_resource_group.nsg-rg.location
  resource_group_name = azurerm_resource_group.nsg-rg.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    environment = "test"
  }
}

# public_ip appvm

resource "azurerm_public_ip" "app-nsg-pip" {
  name                = "app-nsg-pip"
  location            = azurerm_resource_group.nsg-rg.location
  resource_group_name = azurerm_resource_group.nsg-rg.name
  allocation_method   = "Dynamic"

  tags = {
    environment = "test"
  }
}
# public_ip dbvm

resource "azurerm_public_ip" "db-nsg-pip" {

  name                = "db-nsg-pip"
  location            = azurerm_resource_group.nsg-rg.location
  resource_group_name = azurerm_resource_group.nsg-rg.name
  allocation_method   = "Dynamic"

  tags = {
    environment = "test"
  }
}


# network_interface web-nic

resource "azurerm_network_interface" "web-nsg-nic" {
  name                = "web-nsg-nic"
  location            = azurerm_resource_group.nsg-rg.location
  resource_group_name = azurerm_resource_group.nsg-rg.name
  ip_configuration {
    name                          = "web-nsg-ip-config"
    subnet_id                     = azurerm_subnet.nsg-subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.web-nsg-pip.id
  }
}

resource "azurerm_application_security_group" "example" {
  name                = "webvm-appsecuritygroup"
  location            = azurerm_resource_group.nsg-rg.location
  resource_group_name = azurerm_resource_group.nsg-rg.name

  tags = {
    environment = "test"
  }
}

resource "azurerm_network_interface_application_security_group_association" "example" {
  network_interface_id          = azurerm_network_interface.web-nsg-nic.id
  application_security_group_id = azurerm_application_security_group.example.id
}

resource "azurerm_network_interface_application_security_group_association" "example1" {
  network_interface_id          = azurerm_network_interface.app-nsg-nic.id
  application_security_group_id = azurerm_application_security_group.example.id
}
resource "azurerm_network_interface_application_security_group_association" "example2" {
  network_interface_id          = azurerm_network_interface.db-nsg-nic.id
  application_security_group_id = azurerm_application_security_group.example.id
}
# associate nsg to network security group

resource "azurerm_network_interface_security_group_association" "nsg-webvm-associate" {
  network_interface_id      = azurerm_network_interface.web-nsg-nic.id
  network_security_group_id = azurerm_network_security_group.webvm_nsg.id
}



# network_interface app-nic

resource "azurerm_network_interface" "app-nsg-nic" {

  name                = "app-nsg-nic"
  location            = azurerm_resource_group.nsg-rg.location
  resource_group_name = azurerm_resource_group.nsg-rg.name

  ip_configuration {
    name                          = "app-nsg-ip-config"
    subnet_id                     = azurerm_subnet.nsg-subnet2.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.app-nsg-pip.id
  }
}

# associate nsg to network security group

resource "azurerm_network_interface_security_group_association" "nsg-appvm-associate" {
  network_interface_id      = azurerm_network_interface.app-nsg-nic.id
  network_security_group_id = azurerm_network_security_group.appvm_nsg.id
}

# network_interface db-nic

resource "azurerm_network_interface" "db-nsg-nic" {
  name                = "db-nsg-nic"
  location            = azurerm_resource_group.nsg-rg.location
  resource_group_name = azurerm_resource_group.nsg-rg.name

  ip_configuration {
    name                          = "db-nsg-ip-config"
    subnet_id                     = azurerm_subnet.nsg-subnet3.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.db-nsg-pip.id
  }
}

# associate nsg to network security group
resource "azurerm_network_interface_security_group_association" "nsg-dbvm-associate" {
  network_interface_id      = azurerm_network_interface.db-nsg-nic.id
  network_security_group_id = azurerm_network_security_group.dbvm_nsg.id
}

# virtual machine

# azurerm_virtual_machine
resource "azurerm_virtual_machine" "webvm" {
  name                  = "Web-UbuntuMachine"
  location              = azurerm_resource_group.nsg-rg.location
  resource_group_name   = azurerm_resource_group.nsg-rg.name
  network_interface_ids = [azurerm_network_interface.web-nsg-nic.id]
  vm_size               = "Standard_DS1_v2"

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
}

resource "azurerm_virtual_machine" "appvm" {
  name                  = "app-UbuntuMachine"
  location              = azurerm_resource_group.nsg-rg.location
  resource_group_name   = azurerm_resource_group.nsg-rg.name
  network_interface_ids = [azurerm_network_interface.app-nsg-nic.id]
  vm_size               = "Standard_DS1_v2"

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
}

resource "azurerm_virtual_machine" "dbvm" {
  name                  = "db-UbuntuMachine"
  location              = azurerm_resource_group.nsg-rg.location
  resource_group_name   = azurerm_resource_group.nsg-rg.name
  network_interface_ids = [azurerm_network_interface.db-nsg-nic.id]
  vm_size               = "Standard_DS1_v2"

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
    name              = "myosdisk3"
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
}
