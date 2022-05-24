data "template_file" "azure-spoke1-init" {
  template = file("${path.module}/azure-vm-config/azure_bootstrap.sh")
  vars = {
    name     = "BU1-DB"
    password = var.ace_password
  }
}

### Spoke Ubuntu VM 1
resource "azurerm_network_interface" "main" {
  name                = "${var.azure_spoke1_name}-nic1"
  resource_group_name = module.azure_spoke_1.vpc.resource_group
  location            = var.azure_spoke1_region
  ip_configuration {
    name                          = module.azure_spoke_1.vpc.private_subnets[0].name
    subnet_id                     = module.azure_spoke_1.vpc.private_subnets[0].subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_security_group" "spoke1-ubu" {
  name                = "spoke1-ubu"
  resource_group_name = module.azure_spoke_1.vpc.resource_group
  location            = var.azure_spoke1_region
}

resource "azurerm_network_security_rule" "http" {
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "http"
  priority                    = 100
  protocol                    = "Tcp"
  source_port_range           = "*"
  source_address_prefix       = "*"
  destination_port_range      = "80"
  destination_address_prefix  = "*"
  resource_group_name         = module.azure_spoke_1.vpc.resource_group
  network_security_group_name = azurerm_network_security_group.spoke1-ubu.name
}

resource "azurerm_network_security_rule" "ssh" {
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "ssh"
  priority                    = 110
  protocol                    = "Tcp"
  source_port_range           = "*"
  source_address_prefix       = "*"
  destination_port_range      = "22"
  destination_address_prefix  = "*"
  resource_group_name         = module.azure_spoke_1.vpc.resource_group
  network_security_group_name = azurerm_network_security_group.spoke1-ubu.name
}

resource "azurerm_network_security_rule" "icmp" {
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "icmp"
  priority                    = 120
  protocol                    = "Icmp"
  source_port_range           = "*"
  source_address_prefix       = "*"
  destination_port_range      = "*"
  destination_address_prefix  = "*"
  resource_group_name         = module.azure_spoke_1.vpc.resource_group
  network_security_group_name = azurerm_network_security_group.spoke1-ubu.name
}

resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.spoke1-ubu.id
}

resource "azurerm_linux_virtual_machine" "azure_spoke1_vm" {
  name                            = "${var.azure_spoke1_name}-bu1-db"
  resource_group_name             = module.azure_spoke_1.vpc.resource_group
  location                        = var.azure_spoke1_region
  size                            = "Standard_B1ms"
  admin_username                  = "ubuntu"
  admin_password                  = var.ace_password
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  # source_image_reference {
  #   publisher = "canonical"
  #   offer     = "0001-com-ubuntu-server-focal"
  #   version   = "latest"
  # }
  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
  custom_data = base64encode(data.template_file.azure-spoke1-init.rendered)
  tags = {
    name        = "${var.azure_spoke2_name}-bu1-db"
    terraform   = "true"
    environment = "bu1"
  }
}


### Spoke Ubuntu VM 2
data "template_file" "azure-spoke2-init" {
  template = file("${path.module}/azure-vm-config/azure_bootstrap.sh")
  vars = {
    name     = "BU2-DB"
    password = var.ace_password
  }
}

resource "azurerm_network_interface" "main2" {
  name                = "${var.azure_spoke2_name}-nic1"
  resource_group_name = module.azure_spoke_2.vpc.resource_group
  location            = var.azure_spoke2_region
  ip_configuration {
    name                          = module.azure_spoke_2.vpc.private_subnets[0].name
    subnet_id                     = module.azure_spoke_2.vpc.private_subnets[0].subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_security_group" "spoke2-ubu" {
  name                = "spoke2-ubu"
  resource_group_name = module.azure_spoke_2.vpc.resource_group
  location            = var.azure_spoke2_region
}

resource "azurerm_network_security_rule" "http2" {
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "http"
  priority                    = 100
  protocol                    = "Tcp"
  source_port_range           = "*"
  source_address_prefix       = "*"
  destination_port_range      = "80"
  destination_address_prefix  = "*"
  resource_group_name         = module.azure_spoke_2.vpc.resource_group
  network_security_group_name = azurerm_network_security_group.spoke2-ubu.name
}

resource "azurerm_network_security_rule" "ssh2" {
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "ssh"
  priority                    = 110
  protocol                    = "Tcp"
  source_port_range           = "*"
  source_address_prefix       = "*"
  destination_port_range      = "22"
  destination_address_prefix  = "*"
  resource_group_name         = module.azure_spoke_2.vpc.resource_group
  network_security_group_name = azurerm_network_security_group.spoke2-ubu.name
}

resource "azurerm_network_security_rule" "icmp2" {
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "icmp"
  priority                    = 120
  protocol                    = "Icmp"
  source_port_range           = "*"
  source_address_prefix       = "*"
  destination_port_range      = "*"
  destination_address_prefix  = "*"
  resource_group_name         = module.azure_spoke_2.vpc.resource_group
  network_security_group_name = azurerm_network_security_group.spoke2-ubu.name
}

resource "azurerm_network_interface_security_group_association" "main2" {
  network_interface_id      = azurerm_network_interface.main2.id
  network_security_group_id = azurerm_network_security_group.spoke2-ubu.id
}

resource "azurerm_linux_virtual_machine" "azure_spoke2_vm" {
  name                            = "${var.azure_spoke2_name}-bu2-db"
  resource_group_name             = module.azure_spoke_2.vpc.resource_group
  location                        = var.azure_spoke2_region
  size                            = "Standard_B1ms"
  admin_username                  = "ubuntu"
  admin_password                  = var.ace_password
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.main2.id,
  ]
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  # source_image_reference {
  #   publisher = "canonical"
  #   offer     = "0001-com-ubuntu-server-focal"
  #   version   = "latest"
  # }
  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
  custom_data = base64encode(data.template_file.azure-spoke2-init.rendered)
  tags = {
    name        = "${var.azure_spoke2_name}-bu2-db"
    terraform   = "true"
    environment = "bu2"
  }
}
