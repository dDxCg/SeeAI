provider "azurerm" {
  subscription_id = "ef78e1b2-a4fb-4bc4-bbed-2e38ee45a7ba" // <"your_subscription_id">
  features {}
} 

resource "azurerm_resource_group" "seeai" { 
  name = "seeai-rg"
  location = "East Asia"
}

resource "azurerm_virtual_network" "seeai_vpc" { 
  name = "web-vpc" 
  address_space = ["10.1.0.0/16"]
  location = azurerm_resource_group.seeai.location
  resource_group_name = azurerm_resource_group.seeai.name
} 

resource "azurerm_subnet" "backend" {
  name = "backend-subnet" 
  resource_group_name = azurerm_resource_group.seeai.name
  virtual_network_name = azurerm_virtual_network.seeai_vpc.name
  address_prefixes = ["10.1.2.0/24"]
}


resource "azurerm_network_security_group" "backend_nsg" {
  name = "backend-nsg" 
  location = azurerm_resource_group.seeai.location
  resource_group_name = azurerm_resource_group.seeai.name
}

resource "azurerm_network_security_rule" "backend_inbound" {
  name = "allow-backend-http" 
  resource_group_name = azurerm_resource_group.seeai.name
  priority = 100 
  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"
  source_port_range = "*"
  destination_port_range = "8000"
  source_address_prefix = "*"
  destination_address_prefix = "*"
  network_security_group_name = azurerm_network_security_group.backend_nsg.name
}



resource "azurerm_subnet_network_security_group_association" "backend_assoc" {
  subnet_id = azurerm_subnet.backend.id
  network_security_group_id = azurerm_network_security_group.backend_nsg.id
}

resource "azurerm_public_ip" "backend_ip" { 
  name = "backend_ip"
  location = azurerm_resource_group.seeai.location
  resource_group_name = azurerm_resource_group.seeai.name
  allocation_method = "Static" 
  sku = "Standard"
} 



resource "azurerm_network_security_rule" "ssh_inbound_backend" {
  name                        = "allow-ssh-backend"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.seeai.name
  network_security_group_name = azurerm_network_security_group.backend_nsg.name
}


module "backend_vm" { 
  source = "./modules/vm"
  location = azurerm_resource_group.seeai.location
  vm_name = "backend-vm" 
  resource_group_name = azurerm_resource_group.seeai.name
  subnet_id = azurerm_subnet.backend.id
  vm_size = "Standard_B2s"
  os_image = {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
  admin_username = "adminuser"
  ssh_public_key_path = "~/.ssh/seeai.pub" 
  public_ip_id = azurerm_public_ip.backend_ip.id
} 

