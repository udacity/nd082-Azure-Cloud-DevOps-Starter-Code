provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "udacity" {
  name     = "${var.prefix}-resource-group"
  location = var.location
  tags = var.tags
}

resource "azurerm_virtual_network" "udacityVirtualNet" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.udacity.location
  resource_group_name = azurerm_resource_group.udacity.name
  tags                = azurerm_resource_group.udacity.tags
}

resource "azurerm_subnet" "udacitySubNet" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.udacity.name
  virtual_network_name = azurerm_virtual_network.udacityVirtualNet.name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_network_security_group" "udacitySg" {
  name                = "${var.prefix}-sg"
  location            = azurerm_resource_group.udacity.location
  resource_group_name = azurerm_resource_group.udacity.name
  tags                = azurerm_resource_group.udacity.tags

  security_rule {
    name                       = "udacityBlockInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }


  security_rule {
    name                       = "udacityBlockOutbound"
    priority                   = 200
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "udacityAllowInbound"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }


  security_rule {
    name                       = "udacityAllowOutbound"
    priority                   = 201
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

}

resource "azurerm_network_interface" "udacityNic" {
  name                = "${var.prefix}-nic-${count.index}"
  resource_group_name = azurerm_resource_group.udacity.name
  location            = azurerm_resource_group.udacity.location
  tags                = azurerm_resource_group.udacity.tags
  count               = var.vm_count

  ip_configuration {
    name                          = "internal-Ip"
    subnet_id                     = azurerm_subnet.udacitySubNet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_public_ip" "udacityPublicIp" {
  name                = "${var.prefix}-PubIP-${count.index}"
  resource_group_name = azurerm_resource_group.udacity.name
  location            = azurerm_resource_group.udacity.location
  allocation_method   = "Static"
  domain_name_label   = "udacitytest-${count.index}"
  count               = var.vm_count
  tags                = azurerm_resource_group.udacity.tags
  sku                 = "Standard"
}

resource "azurerm_availability_set" "udacityAvailSet" {
  name                = "${var.prefix}-availSet"
  location            = azurerm_resource_group.udacity.location
  resource_group_name = azurerm_resource_group.udacity.name
  tags                = azurerm_resource_group.udacity.tags
  platform_fault_domain_count = var.vm_count

}

resource "azurerm_lb" "udacityLb" {
  name                = "${var.prefix}-lb"
  location            = azurerm_resource_group.udacity.location
  resource_group_name = azurerm_resource_group.udacity.name
  tags                = azurerm_resource_group.udacity.tags
  sku                 = "Standard"
  count               = length(azurerm_public_ip.udacityPublicIp)

  frontend_ip_configuration {
    name                 = "PublicIPAddressLb-${count.index}"
    public_ip_address_id = azurerm_public_ip.udacityPublicIp[count.index].id
  }
}


resource "azurerm_lb_backend_address_pool" "udacitylbPool" {
  count               = length(azurerm_lb.udacityLb)
  loadbalancer_id     = azurerm_lb.udacityLb[count.index].id
  name                = "${var.prefix}-lbpool-${count.index}"
}

resource "azurerm_network_interface_backend_address_pool_association" "udacityBE" {
  count                   = length(azurerm_network_interface.udacityNic)
  network_interface_id    = azurerm_network_interface.udacityNic[count.index].id
  ip_configuration_name   = "internal-Ip"
  backend_address_pool_id = azurerm_lb_backend_address_pool.udacitylbPool[count.index].id

}

resource "azurerm_linux_virtual_machine" "udacityVM" {
  name                            = "${var.prefix}-vm-${count.index}"
  resource_group_name             = azurerm_resource_group.udacity.name
  location                        = azurerm_resource_group.udacity.location
  size                            = "Standard_F2"
  availability_set_id             = azurerm_availability_set.udacityAvailSet.id
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false
  count                           = var.vm_count
  tags                            = azurerm_resource_group.udacity.tags
  network_interface_ids = [azurerm_network_interface.udacityNic[count.index].id]
  source_image_id = var.imageid
  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}
