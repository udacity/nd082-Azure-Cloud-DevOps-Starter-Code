provider "azurerm" {
  features {}
}

# Create resource group
resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-rg"
  location = var.location
  tags = {
  infrastructure = "project-1" }
}

# Create AAS
resource "azurerm_availability_set" "main" {
  name                         = "${var.prefix}-aset"
  location                     = azurerm_resource_group.main.location
  resource_group_name          = azurerm_resource_group.main.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
  tags = {
    infrastructure = "project-1"
  }
}
# Create virtual network - Done
resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = [var.addressprefix]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags = {
    infrastructure = "project-1"
  }
}

# Create subnet - Done
resource "azurerm_subnet" "main" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.subnetprefix]
}

# Create NSG - Done
resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags = {
    infrastructure = "project-1"
  }

  security_rule {
    name                       = "allowVNet-Inbound"
    priority                   = 800
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VNet"
    destination_address_prefix = "VNet"
  }
  // added a network security group that restricts access to virtual machines from outside the vnet
  security_rule {
    name                       = "DenyInternetInbound"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "VNet"

  }
  security_rule {
    name                       = "allowVNet-Outbound"
    priority                   = 400
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VNet"
    destination_address_prefix = "VNet"
  }
}

# Create network interface - Done
resource "azurerm_network_interface" "main" {
  count               = var.num_of_vms
  name                = "${var.prefix}-${count.index}-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  //location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "ipconfig${var.prefix}"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
  tags = {
    infrastructure = "project-1"
  }
}

# Create public ip - Done
resource "azurerm_public_ip" "main" {
  name                = "${var.prefix}-vm-ip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
  tags = {
    infrastructure = "project-1"
  }
}

# Create Load Balancer - Done
resource "azurerm_lb" "main" {
  name                = "${var.prefix}-lb"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.main.id
  }
}

resource "azurerm_lb_backend_address_pool" "main" {
  resource_group_name = azurerm_resource_group.main.name
  loadbalancer_id     = azurerm_lb.main.id
  name                = "BackEndAddressPool"
}

# Create a linux virtual machine
resource "azurerm_linux_virtual_machine" "main" {
  count               = var.vm_instances
  name                = "${var.prefix}-vm-${count.index}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = var.vm_size
  availability_set_id = azurerm_availability_set.main.id

  disable_password_authentication = false
  network_interface_ids           = [element(azurerm_network_interface.main.*.id, count.index)]

  tags = {
    infrastructure = "project-1"
  }

  computer_name  = "myvm"
  admin_username = "azureuser"

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}
