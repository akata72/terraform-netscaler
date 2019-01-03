variable "name" {}
variable "location" {}
variable "resource_group_name" {}
variable "network_security_group_id" {}
variable "subnet_id" {}
variable "private_ip_address" {}   
variable "public_ip_address_id" {}   

resource "azurerm_network_interface" "main" {
  name                      = "${var.name}"
  location                  = "${var.location}"
  resource_group_name       = "${var.resource_group_name}"
  network_security_group_id = "${var.network_security_group_id}"

  ip_configuration {
    name                          = "private-ip"
    subnet_id                     = "${var.subnet_id}"
    private_ip_address_allocation = "static"
    private_ip_address            = "${var.private_ip_address}"
    public_ip_address_id          = "${var.public_ip_address_id}"
  }
}
