# 1. Install az cli in local machin- macOS

brew update && brew install azure-cli

# 2. login to az cli

az login

# 3. run list

az account list

if you have more than one Subscription, you can specify the Subscription to use via the following command:

**az account set --subscription="SUBSCRIPTION_ID"**

                            **<!-- Configuration -->**

**subnet_configuration**:

In this example, the subnet_map local variable is a map of subnet names to address prefixes. The azurerm_subnet resource block is then defined using the count argument, with the length of the subnet_names list. This will create as many instances of the azurerm_subnet resource as there are names in the subnet_names list.

The name argument is set to the name of the subnet using the count.index to reference the current iteration of the loop. The address_prefixes argument is set to the address prefix of the subnet by using the count.index to reference the correct subnet name from the subnet_names list and using the subnet name to look up the correct address prefix in the subnet_map local variable.

In this way, the specific IP range will be mapped to the specific subnet name, regardless of the order in which the subnet names are listed in the subnet_names variable.

**<!-- network security group -->**
This is a Terraform code block that creates an Azure network security group resource. The network security group acts as a firewall, controlling inbound and outbound network traffic to the resources in the Azure virtual network.

The following details are specified in the code block:

**name**: The name of the network security group.
**location and resource_group_name**: The location and resource group where the network security group will be created.
**security_rule**: This block defines the rules that dictate which network traffic is allowed or denied. There are five rules defined in this code block. Each rule defines the following properties:
**name**: A unique name for the rule.
**priority**: The priority of the rule. Lower priority values take precedence over higher priority values.
**direction**: The direction of the network traffic. In this case, it is set to "Inbound" for incoming traffic.
**access**: The action to be taken on network traffic that matches the rule. It is set to "Allow" for all the rules defined in this code block, allowing the specified traffic.
**protocol**: The network protocol for which the rule applies. It can be set to TCP, UDP, or ICMP.
**source_port_range and destination_port_range:** The source and destination port ranges for which the rule applies.
**source_address_prefix and destination_address_prefix:** The source and destination IP address ranges for which the rule applies.
**tags**: Key-value pairs that can be used to categorize and organize resources in Azure. In this case, a single tag with the key "environment" and value "Production" is defined.

This code block creates a network security group that allows incoming network traffic over SSH (port 22), HTTP (port 80), HTTPS (port 443), RDP (port 3389), and ICMP protocols. The traffic is allowed from any source IP address to any destination IP address.

**protocols explained:**

1. **ICMP (Internet Control Message Protocol)** is a network protocol used for error reporting and status information between network devices, such as routers or computers. It operates at the Network Layer (layer 3) of the OSI model. ICMP messages are typically used to report errors or issues in the network, such as unreachable destinations, time-exceeded messages, or other conditions that prevent the successful delivery of data packets. For example, the well-known "ping" command uses ICMP to determine the connectivity and response time of a networked device.
2. **The SSH (Secure Shell)** protocol, commonly used to log into a remote machine and execute commands, uses port 22. It operates at the Transport Layer (Layer 4) of the OSI Model, providing secure encrypted communications between two untrusted hosts over an insecure network.

3.**The HTTP (Hypertext Transfer Protocol)** protocol, used for transmitting data over the web, uses port 80. It operates at the Application Layer (Layer 7) of the OSI Model and is the foundation of data communication for the World Wide Web.

4. **HTTPS (HTTP Secure)**, an extension of HTTP, is used to securely transmit data over the web. It operates at the Application Layer (Layer 7) of the OSI Model and uses port 443. It is encrypted using Transport Layer Security (TLS) or Secure Sockets Layer (SSL) protocols to provide secure communication.

5. **The RDP (Remote Desktop Protocol) protocol**, used to remotely access and control a computer, uses port 3389. It operates at the Application Layer (Layer 7) of the OSI Model and allows for the graphical display of a remote desktop session, as well as input from the local computer to the remote computer.

**<!-- The Open Systems Interconnection (OSI) model -->**
The Open Systems Interconnection (OSI) model is a reference model for communication in computer networks. It divides network communication into 7 layers:

1. Physical Layer: This layer deals with the physical transfer of data, including transmission media, data rates, and modulation techniques. Example protocols: Ethernet, Wi-Fi, and Bluetooth.

2. Data Link Layer: This layer is responsible for ensuring that data is transferred reliably from one device to another on the same network segment. Example protocols: ARP, LLC, and MAC.

3. Network Layer: This layer is responsible for routing data packets between different networks. Example protocols: IPv4, IPv6, and ICMP.

4. Transport Layer: This layer is responsible for providing reliable and efficient data transmission between applications running on different hosts. Example protocols: TCP and UDP.

5. Session Layer: This layer is responsible for managing sessions between applications and synchronizing their communication. Example protocols: SCTP and DCCP.

6. Presentation Layer: This layer is responsible for data representation and encryption. Example protocols: SSL and TLS.

7. Application Layer: This layer is responsible for providing services directly to applications and is closest to the end-user. Example protocols: HTTP, FTP, and SMTP.

**<!-- azurerm_public_ip_address -->**

azurerm_public_ip_address is a Terraform resource in the Azure Resource Manager (AzureRM) provider that allows you to create a public IP address in Microsoft Azure. The resource is used to associate a public IP address with a virtual machine, allowing it to be accessible from the internet. The public IP address resource can be configured with properties such as the IP address version (IPv4 or IPv6), static or dynamic allocation, and the associated domain name system (DNS) label. The created public IP address can then be used as a reference in other resources, such as network security groups or load balancers, to control network access.

**<!-- Azurerm_network_interface -->**

Azurerm_network_interface is a Terraform resource type that creates a network interface in Azure. Network Interfaces are an essential component of an Azure virtual machine (VM) as they provide communication between the VM and the internet, Azure virtual network, or on-premises network.

A network interface can have one or more IP configurations. In this Terraform code, a single IP configuration is defined within the ip_configuration block of the azurerm_network_interface resource.

In this block, the following properties are specified:

**name**: name of the IP configuration
**subnet_id**: the ID of the Azure subnet to associate with the network interface
**private_ip_address_allocation**: the allocation method of the private IP address. Either "Dynamic" or "Static"
**public_ip_address_id**: the ID of the public IP address to associate with the network interface, if desired.
This azurerm_network_interface resource will be created using the specified parameters and will be associated with a specific virtual machine created by the azurerm_virtual_machine resource.

you can have multiple IP configurations within a single azurerm_network_interface block, and each IP configuration can be assigned to a different virtual machine. This allows you to configure multiple private IP addresses and associate each one with a different virtual machine.

**<!-- azurerm_virtual_machine -->**

azurerm_virtual_machine is a Terraform resource block that represents an Azure Virtual Machine. It consists of several configuration options that define the behavior and properties of the virtual machine.

**Explanation of each configuration option in the azurerm_virtual_machine block:**
**name**: This is the name of the virtual machine.

**location**: This is the location or the region in which the virtual machine will be created.

**resource_group_name**: This is the name of the resource group in which the virtual machine will be created.

**network_interface_ids**: This is an array of network interface IDs that the virtual machine will use.

**vm_size**: This is the size of the virtual machine, which determines the amount of resources such as CPU, memory, and storage that will be allocated to it.

**delete_os_disk_on_termination**: This is a boolean option that determines whether the operating system disk will be deleted when the virtual machine is deleted.

**delete_data_disks_on_termination**: This is a boolean option that determines whether the data disks will be deleted when the virtual machine is deleted.

**storage_image_reference**: This is a configuration block that contains information about the image that will be used to create the virtual machine's operating system disk.

**storage_os_disk**: This is a configuration block that contains properties for the operating system disk.
The OS disk is a virtual disk that is used to store the operating system and its files. It is typically the first disk attached to a virtual machine, and it is required for the virtual machine to boot and run properly.

**storage_data_disk**(optional): Data disks, on the other hand, are virtual disks that can be attached to a virtual machine for the purpose of storing additional data. They are optional and can be added as needed. Unlike the OS disk, data disks can be added or removed at any time without affecting the operation of the virtual machine.

**os_profile**: This is a configuration block that contains information about the operating system and the local administrator account for the virtual machine.

**os_profile_linux_config**: This is a configuration block that contains configuration options for a Linux operating system.

**tags**: This is a map of key-value pairs that can be used to categorize the virtual machine for management and organization purposes.

**Summury**:
This Terraform code creates an Azure Resource Group, Virtual Network, Subnets, Network Security Group, Public IP, Network Interface, and Virtual Machine.

The Resource Group "AzureRg" is created in the "East US" location. The virtual network "AzureNetwork" is created within the resource group with the address space 10.30.0.0/16. Subnets are created based on the count of subnet names specified in the variable "subnet_names" and their address prefixes are mapped in the "subnet_map" local. The Network Security Group "AzureNetworkSecurityGroup" is created with 5 inbound security rules to allow traffic over SSH, HTTP, HTTPS, RDP, and ICMP protocols.

A public IP "public-ip-address" is created and attached to the Network Interface "AzureNIC", which is created based on the count of subnet names. A virtual machine is also created using the network interface, but the details of it are not specified in this code snippet.

**prerequisites:**

1. An Azure subscription
2. A Resource Group created in the Azure subscription
3. A Virtual Network created in the Resource Group
4. Subnets created within the Virtual Network
5. A Network Security Group created in the Resource Group
6. A Public IP address created in the Resource Group(optional)
7. Network Interfaces (NICs) created in the Resource Group
8. A Storage Account for the virtual machine's disk
9. A Virtual Machine Image for the operating system
   These resources must be created before the virtual machine resource in the Terraform code can be created.
