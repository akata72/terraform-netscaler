variable "name" { }
variable "environment" {}
variable "common_tags" { 
    type = "map"
}

variable "availability_set_id" {}
variable "location" {}
variable "resource_group_name" {}
variable "network_interface_ids" { type = "list" }
variable "primary_network_interface_id" {}
variable "vm_size" {
    default = "Standard_B2ms"
}
variable "admin_username" {
    default = "nsadmin"
}
variable "admin_password" {}
