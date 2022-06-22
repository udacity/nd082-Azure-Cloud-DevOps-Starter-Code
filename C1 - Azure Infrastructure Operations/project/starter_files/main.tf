provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "fpt" {
  name     = "${var.prefix}-resource-group"
  location = var.location
  tags = var.tags
}

resource "azurerm_virtual_network" "fptVirtualNet" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.fpt.location
  resource_group_name = azurerm_resource_group.fpt.name
  tags                = azurerm_resource_group.fpt.tags
}

resource "azurerm_subnet" "fptSubNet" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.fpt.name
  virtual_network_name = azurerm_virtual_network.fptVirtualNet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_security_group" "fptSg" {
  name                = "${var.prefix}-sg"
  location            = azurerm_resource_group.fpt.location
  resource_group_name = azurerm_resource_group.fpt.name
  tags                = azurerm_resource_group.fpt.tags

  security_rule {
    name                       = "fptBlockInbound"
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
    name                       = "fptBlockOutbound"
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
    name                       = "fptAllowInbound"
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
    name                       = "fptAllowOutbound"
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

resource "azurerm_network_interface" "fptNic" {
  name                = "${var.prefix}-nic-${count.index}"
  resource_group_name = azurerm_resource_group.fpt.name
  location            = azurerm_resource_group.fpt.location
  tags                = azurerm_resource_group.fpt.tags
  count               = var.vm_count

  ip_configuration {
    name                          = "internal-Ip"
    subnet_id                     = azurerm_subnet.fptSubNet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_public_ip" "fptPublicIp" {
  name                = "${var.prefix}-PubIP-${count.index}"
  resource_group_name = azurerm_resource_group.fpt.name
  location            = azurerm_resource_group.fpt.location
  allocation_method   = "Static"
  domain_name_label   = "fpttest-${count.index}"
  count               = var.vm_count
  tags                = azurerm_resource_group.fpt.tags
  sku                 = "Standard"
}

resource "azurerm_availability_set" "fptAvailSet" {
  name                = "${var.prefix}-availSet"
  location            = azurerm_resource_group.fpt.location
  resource_group_name = azurerm_resource_group.fpt.name
  tags                = azurerm_resource_group.fpt.tags
  platform_fault_domain_count = var.vm_count

}

resource "azurerm_lb" "fptLb" {
  name                = "${var.prefix}-lb"
  location            = azurerm_resource_group.fpt.location
  resource_group_name = azurerm_resource_group.fpt.name
  tags                = azurerm_resource_group.fpt.tags
  sku                 = "Standard"
  count               = length(azurerm_public_ip.fptPublicIp)

  frontend_ip_configuration {
    name                 = "PublicIPAddressLb-${count.index}"
    public_ip_address_id = azurerm_public_ip.fptPublicIp[count.index].id
  }
}


resource "azurerm_lb_backend_address_pool" "fptlbPool" {
  count               = length(azurerm_lb.fptLb)
  resource_group_name = azurerm_resource_group.fpt.name
  loadbalancer_id     = azurerm_lb.fptLb[count.index].id
  name                = "${var.prefix}-lbpool-${count.index}"
}

resource "azurerm_network_interface_backend_address_pool_association" "fptBE" {
  count                   = length(azurerm_network_interface.fptNic)
  network_interface_id    = azurerm_network_interface.fptNic[count.index].id
  ip_configuration_name   = "internal-Ip"
  backend_address_pool_id = azurerm_lb_backend_address_pool.fptlbPool[count.index].id

}

resource "azurerm_linux_virtual_machine" "fptVM" {
  name                            = "${var.prefix}-vm-${count.index}"
  resource_group_name             = azurerm_resource_group.fpt.name
  location                        = azurerm_resource_group.fpt.location
  size                            = "Standard_F2"
  availability_set_id             = azurerm_availability_set.fptAvailSet.id
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false
  count                           = var.vm_count
  tags                            = azurerm_resource_group.fpt.tags
  network_interface_ids = [azurerm_network_interface.fptNic[count.index].id]
  source_image_id = var.imageid
  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}