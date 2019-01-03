
variable "resource_group_name" { }
variable "name"{}
variable "frontend_ip_id" {}
variable "location"{}
variable "common_tags" { 
    type = "map"
}
variable "network_interface_ids" {
    type = "list"
  #  value = ["${azurerm_network_interface.ext-nic0.id}","${azurerm_network_interface.ext-nic1.id}"]
}