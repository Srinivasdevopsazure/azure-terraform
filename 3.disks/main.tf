locals {
  subnet_map = {
    "WebServer" = "10.30.10.0/28",
    "AppServer" = "10.30.10.32/27",
    "DbServer"  = "10.30.10.64/26",
  }
}

variable "lun" {
  default = 1
}
# Create a resource group
resource "azurerm_resource_group" "arg" {
  name     = "AzureRg"
  location = "East US"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "avn" {
  name                = "AzureNetwork"
  resource_group_name = azurerm_resource_group.arg.name
  location            = azurerm_resource_group.arg.location
  address_space       = ["10.30.0.0/16"]
}

# azurerm_subnet
resource "azurerm_subnet" "subNets" {
  count                = length(var.subnet_names)
  name                 = var.subnet_names[count.index]
  resource_group_name  = azurerm_resource_group.arg.name
  virtual_network_name = azurerm_virtual_network.avn.name
  address_prefixes     = [local.subnet_map[var.subnet_names[count.index]]]
}

# azurerm_network_security_group

resource "azurerm_network_security_group" "nsg" {
  name                = "AzureNetworkSecurityGroup"
  location            = azurerm_resource_group.arg.location
  resource_group_name = azurerm_resource_group.arg.name

  security_rule {
    name                       = "allow_ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_http"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_https"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_rdp"
    priority                   = 103
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_icmp"
    priority                   = 104
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "test"
  }
}

# azurerm_public_ip_address
resource "azurerm_public_ip" "example" {
  name                = "public-ip-address"
  location            = azurerm_resource_group.arg.location
  resource_group_name = azurerm_resource_group.arg.name
  allocation_method   = "Static"
}

# azurerm_network_interface
resource "azurerm_network_interface" "main" {
  count               = length(var.subnet_names)
  name                = "AzureNIC"
  location            = azurerm_resource_group.arg.location
  resource_group_name = azurerm_resource_group.arg.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.subNets[0].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}

# azurerm_virtual_machine
resource "azurerm_virtual_machine" "main" {
  name                  = "UbuntuMachine"
  location              = azurerm_resource_group.arg.location
  resource_group_name   = azurerm_resource_group.arg.name
  network_interface_ids = [azurerm_network_interface.main[0].id]
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
  storage_data_disk {
    name              = "example-data-disk"
    managed_disk_type = "Standard_LRS"
    disk_size_gb      = "5"
    create_option     = "Empty"
    lun               = var.lun
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "test"
  }

}
resource "null_resource" "data_disk" {

  provisioner "remote-exec" {
    inline = [
      # Create a partition on the data disk
      "device_name=$(printf \"/dev/sd%c\" $(echo \"98 + ${var.lun}\" | bc))",
      "echo ${device_name}",
      "sudo parted ${device_name} mklabel gpt",
      "sudo parted {device_name} mkpart primary ext4 0% 100%",

      # Format the data disk
      "sudo mkfs.ext4 {device_name}",

      # Create a mount point for the data disk
      "sudo mkdir /mnt/datadisk",

      # Mount the data disk
      "sudo mount {device_name} /mnt/datadisk",

      # Add an entry to /etc/fstab to mount the disk on boot
      "echo '{device_name} /mnt/datadisk ext4 defaults 0 0' | sudo tee -a /etc/fstab"
    ]

    connection {
      type     = "ssh"
      user     = "testadmin"
      password = "Password1234!"
      host     = azurerm_public_ip.example.ip_address
      timeout  = "60s"
    }
  }
  depends_on = [azurerm_virtual_machine.main]
}
