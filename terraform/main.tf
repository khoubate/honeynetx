resource "azurerm_resource_group" "honeynetx-rg" {
  name     = "${var.prefix}-resources"
  location = var.location
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.honeynetx-rg.location
  resource_group_name = azurerm_resource_group.honeynetx-rg.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.honeynetx-rg.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_security_group" "honeynetx-nsg" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.honeynetx-rg.location
  resource_group_name = azurerm_resource_group.honeynetx-rg.name

  security_rule {
    name                       = "AllowSSH"
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
    name                       = "AllowWebInterface"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "64297"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "honeynetx-vm-nsg-association" {
  subnet_id                 = azurerm_subnet.internal.id
  network_security_group_id = azurerm_network_security_group.honeynetx-nsg.id
}

resource "azurerm_public_ip" "honeynetx-vm-ip" {
  name                = "${var.prefix}-vm-ip"
  location            = azurerm_resource_group.honeynetx-rg.location
  resource_group_name = azurerm_resource_group.honeynetx-rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "honeynetx-vm-nic" {
  name                = "${var.prefix}-vm-nic"
  location            = azurerm_resource_group.honeynetx-rg.location
  resource_group_name = azurerm_resource_group.honeynetx-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.honeynetx-vm-ip.id
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  name                = "${var.prefix}-vm"
  location            = azurerm_resource_group.honeynetx-rg.location
  resource_group_name = azurerm_resource_group.honeynetx-rg.name
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.honeynetx-vm-nic.id,
  ]

  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

resource "null_resource" "copy_installer" {
  depends_on = [azurerm_linux_virtual_machine.main]

  connection {
    type     = "ssh"
    user     = var.admin_username
    password = var.admin_password
    host     = azurerm_public_ip.honeynetx-vm-ip.ip_address
  }

  provisioner "file" {
    source      = "../scripts/install_hnetx.sh"
    destination = "/home/azureuser/install_hnetx.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/azureuser/install_hnetx.sh",
     
    ]
  }
}