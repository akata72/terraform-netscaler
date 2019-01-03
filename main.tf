terraform {
  required_version = "0.11.10"
}

locals {
  common_tags = {
    environment = "${var.environment}"
    departement = "dep"
    owner = "owner"
    routine = "routine"
    project = "project"
    provisionedby = "Terraform"
  }
}


########## DATA ##########

# Reference the virtual network
data "azurerm_virtual_network" "main" {
  name                = "${var.vnet}"
  resource_group_name = "${var.vnet_resource_group}"
}

# Reference the subnet
data "azurerm_subnet" "gateway-external-subnet" {
  name = "gateway-external-subnet"
  virtual_network_name = "${data.azurerm_virtual_network.main.name}"
  resource_group_name  = "${data.azurerm_virtual_network.main.resource_group_name}"
}

data "azurerm_subnet" "gateway-mgt-subnet" {
  name = "gateway-mgt-subnet"
  virtual_network_name = "${data.azurerm_virtual_network.main.name}"
  resource_group_name  = "${data.azurerm_virtual_network.main.resource_group_name}"
}

data "azurerm_subnet" "gateway-internal-subnet" {
  name = "gateway-internal-subnet"
  virtual_network_name = "${data.azurerm_virtual_network.main.name}"
  resource_group_name  = "${data.azurerm_virtual_network.main.resource_group_name}"
}

# Reference the resource group where the dns zone is located.
data "azurerm_resource_group" "dnsrg" {
  name = "${var.dnszone_resource_group}"
}

# Reference the DNS zone where we will create the records for netscaler.
data "azurerm_dns_zone" "zone" {
  name = "${var.domain}"
}

# Reference the keyvault where nsadmin password will be stored temporary.
data "azurerm_key_vault" "vault" {
  name = "${var.keyvault_name}"
  resource_group_name = "${var.keyvault_resource_group_name}"
}

########## RESOURCES ##########

resource "random_string" "password" {
  length = 23
  special = true
}

## Put the initial netscaler password in the existing keyvault
resource "azurerm_key_vault_secret" "netscaler" {
  name = "netscaler-password"
  value = "${random_string.password.result}"
  vault_uri = "${data.azurerm_key_vault.vault.vault_uri}"
}

resource "azurerm_dns_a_record" "vpn" {
  name                = "${var.netscalergw}"
  zone_name           = "${data.azurerm_dns_zone.zone.name}"
  resource_group_name = "${data.azurerm_resource_group.dnsrg.name}"
  ttl                 = 300
  records             = ["${azurerm_public_ip.vpn.ip_address}"]
}

resource "azurerm_dns_a_record" "vpx1" {
  name                = "${var.prefix}1"
  zone_name           = "${data.azurerm_dns_zone.zone.name}"
  resource_group_name = "${data.azurerm_resource_group.dnsrg.name}"
  ttl                 = 300
  records             = ["${azurerm_public_ip.vpx1.ip_address}"]
}

resource "azurerm_dns_a_record" "vpx2" {
  name                = "${var.prefix}2"
  zone_name           = "${data.azurerm_dns_zone.zone.name}"
  resource_group_name = "${data.azurerm_resource_group.dnsrg.name}"
  ttl                 = 300
  records             = ["${azurerm_public_ip.vpx2.ip_address}"]
} 

# Create a Resource Group for the Netscaler resources.
resource "azurerm_resource_group" "main" {
  name     = "${var.resource_group}"
  location = "${var.location}"
  tags     = "${local.common_tags}"
}

# Create a Public IP to be used for netscaler management
resource "azurerm_public_ip" "vpx1" {
  name                         = "${var.prefix}1-nsip-pip"
  location                     = "${azurerm_resource_group.main.location}"
  resource_group_name          = "${azurerm_resource_group.main.name}"
  public_ip_address_allocation = "static"
  tags                         = "${local.common_tags}"
}

# Create a Public IP to be used for netscaler management
resource "azurerm_public_ip" "vpx2" {
  name                         = "${var.prefix}2-nsip-pip"
  location                     = "${azurerm_resource_group.main.location}"
  resource_group_name          = "${azurerm_resource_group.main.name}"
  public_ip_address_allocation = "static"
  tags                         = "${local.common_tags}"
}

# Create a Public IP to be used for the loadbalanced vpn service
resource "azurerm_public_ip" "vpn" {
  name                         = "${var.prefix}-vpn-pip"
  location                     = "${azurerm_resource_group.main.location}"
  resource_group_name          = "${azurerm_resource_group.main.name}"
  public_ip_address_allocation = "static"
  tags                         = "${local.common_tags}"
}

# Create the Network Security Groups for netscaler
resource "azurerm_network_security_group" "mgt" {
  name                = "${var.prefix}-mgt-nsg"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  tags = "${local.common_tags}"

  security_rule {
    name                       = "AllowSshInBound"
    description                = "Allow SSH access"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHttpsInBound"
    description                = "Allow HTTPS access"
    priority                   = 1010
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Autoscale-Daemon"
    description                = "Autoscale-Daemon"
    priority                   = 1020
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9001"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "ext" {
  name                = "${var.prefix}-ext-nsg"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  tags = "${local.common_tags}"

  security_rule {
    name                       = "AllowHttpsInBound"
    description                = "Allow HTTPS access"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "int" {
  name                = "${var.prefix}-int-nsg"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  tags = "${local.common_tags}"

  security_rule {
    name                       = "AllowHttpsInBound"
    description                = "Allow HTTPS access"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create a network interface for VMs and attach the PIP and the NSG
resource "azurerm_network_interface" "vpx1-nic0" {
  name                      = "${var.prefix}1-nic0"
  location                  = "${azurerm_resource_group.main.location}"
  resource_group_name       = "${azurerm_resource_group.main.name}"
  network_security_group_id = "${azurerm_network_security_group.mgt.id}"
  tags                      = "${local.common_tags}"

  ip_configuration {
    name                          = "nsip-ip"
    subnet_id                     = "${data.azurerm_subnet.gateway-mgt-subnet.id}"

    private_ip_address_allocation = "static"
    private_ip_address            = "${var.nsip-ip}"
    public_ip_address_id          = "${azurerm_public_ip.vpx1.id}"
  }
}

resource "azurerm_network_interface" "vpx1-nic1" {
  name                      = "${var.prefix}1-nic1"
  location                  = "${azurerm_resource_group.main.location}"
  resource_group_name       = "${azurerm_resource_group.main.name}"
  network_security_group_id = "${azurerm_network_security_group.ext.id}"
  tags                      = "${local.common_tags}"

  ip_configuration {
    name                          = "external-ip"
    subnet_id                     = "${data.azurerm_subnet.gateway-external-subnet.id}"
    private_ip_address_allocation = "static"
    private_ip_address            = "${var.external-ip}"
  }
} 

resource "azurerm_network_interface" "vpx1-nic2" {
  name                      = "${var.prefix}1-nic2"
  location                  = "${azurerm_resource_group.main.location}"
  resource_group_name       = "${azurerm_resource_group.main.name}"
  network_security_group_id = "${azurerm_network_security_group.int.id}"
  tags                      = "${local.common_tags}"

  ip_configuration {
    name                          = "internal-ip"
    subnet_id                     = "${data.azurerm_subnet.gateway-internal-subnet.id}"
    private_ip_address_allocation = "static"
    private_ip_address            = "${var.internal-ip}"
  }
} 

# Create a network interface for VMs and attach the PIP and the NSG
resource "azurerm_network_interface" "vpx2-nic0" {
  name                      = "${var.prefix}2-nic0"
  location                  = "${azurerm_resource_group.main.location}"
  resource_group_name       = "${azurerm_resource_group.main.name}"
  network_security_group_id = "${azurerm_network_security_group.mgt.id}"
  tags                      = "${local.common_tags}"

  ip_configuration {
    name                          = "nsip-ip"
    subnet_id                     = "${data.azurerm_subnet.gateway-mgt-subnet.id}"
    private_ip_address_allocation = "static"
    private_ip_address            = "${var.nsip-ip-secondary}"
    public_ip_address_id          = "${azurerm_public_ip.vpx2.id}"
  }
}

resource "azurerm_network_interface" "vpx2-nic1" {
  name                      = "${var.prefix}2-nic1"
  location                  = "${azurerm_resource_group.main.location}"
  resource_group_name       = "${azurerm_resource_group.main.name}"
  network_security_group_id = "${azurerm_network_security_group.ext.id}"
  tags                      = "${local.common_tags}"

  ip_configuration {
    name                          = "external-ip"
    subnet_id                     = "${data.azurerm_subnet.gateway-external-subnet.id}"

    private_ip_address_allocation = "static"
    private_ip_address            = "${var.external-ip-secondary}"
  }
} 

resource "azurerm_network_interface" "vpx2-nic2" {
  name                      = "${var.prefix}2-nic2"
  location                  = "${azurerm_resource_group.main.location}"
  resource_group_name       = "${azurerm_resource_group.main.name}"
  network_security_group_id = "${azurerm_network_security_group.int.id}"
  tags                      = "${local.common_tags}"

  ip_configuration {
    name                          = "internal-ip"
    subnet_id                     = "${data.azurerm_subnet.gateway-internal-subnet.id}"

    private_ip_address_allocation = "static"
    private_ip_address            = "${var.internal-ip-secondary}"
  }
} 

# Create the availability set where the Netscalers will belong.
resource "azurerm_availability_set" "main" {
  name        = "${var.prefix}-availabilityset"
  location    = "${var.location}"
  managed     = "true"
  resource_group_name = "${azurerm_resource_group.main.name}"
  tags                = "${local.common_tags}"
}

module "vpx-loadbalancer" {
  source = "./modules/netscaler-lb"
  location = "${var.location}"
  common_tags = "${local.common_tags}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  name = "${var.prefix}-loadbalancer"
  frontend_ip_id = "${azurerm_public_ip.vpn.id}" 
  network_interface_ids = ["${azurerm_network_interface.vpx1-nic1.id}","${azurerm_network_interface.vpx2-nic1.id}"]  
}

module "vpx1" {
  name = "${var.prefix}1"
  environment = "${var.environment}"
  common_tags = "${local.common_tags}"
  source = "./modules/netscaler-vm"
  resource_group_name = "${azurerm_resource_group.main.name}"
  availability_set_id = "${azurerm_availability_set.main.id}"
  location = "${var.location}"
  network_interface_ids = ["${azurerm_network_interface.vpx1-nic0.id}","${azurerm_network_interface.vpx1-nic1.id}","${azurerm_network_interface.vpx1-nic2.id}"]  
  primary_network_interface_id = "${azurerm_network_interface.vpx1-nic0.id}"
  vm_size = "${var.vm_size}"
  admin_username = "${var.admin_username}"
  admin_password = "${random_string.password.result}"
}

module "vpx2" {
  name = "${var.prefix}2"
  environment = "${var.environment}"
  common_tags = "${local.common_tags}"
  source = "./modules/netscaler-vm"
  resource_group_name = "${azurerm_resource_group.main.name}"
  availability_set_id = "${azurerm_availability_set.main.id}"
  location = "${var.location}" 
  network_interface_ids = ["${azurerm_network_interface.vpx2-nic0.id}","${azurerm_network_interface.vpx2-nic1.id}","${azurerm_network_interface.vpx2-nic2.id}"]
  primary_network_interface_id = "${azurerm_network_interface.vpx2-nic0.id}" 
  vm_size = "${var.vm_size}"
  admin_username = "${var.admin_username}"
  admin_password = "${random_string.password.result}"
}
