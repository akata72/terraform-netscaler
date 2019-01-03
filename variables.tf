########## VARIABLES ##########

variable "environment" {
  default = "development"
}

variable "resource_group" {
  description = "The name of the resource group where resources will be provisioned."
  default = "dnb-gf-tf-netscaler-ha-multinic-rg"
}

variable "vm_size" {
  default = "Standard_B2ms"
}

variable "dnszone_resource_group" {
  description = "The name of the resource group where the DNZ zone exists."
  default = "dnb-gf-tf-dns-rg"
}

variable "vnet_resource_group" {
  description = "The name of the resource group where the vnets are located."
  default = "dnb-gf-tf-virtualnetworks-rg"
}

variable "vnet" {
  default = "dnbgf-exposed-tf-vnet"
}

variable "domain" {
  default = "tech-01-dev.net"
}

variable "netscalergw" {
  default = "access"
}

variable "location" {
  description = "The region where resources will be provisioned."
  default = "northeurope"
}

variable "prefix" {
  description = "The prefix used for most resources used, must be an alphanumberic string"
  default ="netscaler"
}

variable "admin_username" {
  description = "The username associated with the local administrator account on the netscaler"
  default = "nsadmin"
}

variable "keyvault_name" {
  description = "The keyvault where temporary secrets will be stored."
  default = "dnbgftfvault"
}

variable "keyvault_resource_group_name" {
  description = "The resource group where the keyvault is located."
  default = "dnb-gf-tf-keyvault-rg"
}

variable "nsip-ip" {
  description = "The management IP (nsip) of the Netscaler resource."
  default = "10.78.225.132"
}
variable "nsip-ip-secondary" {
  description = "The management IP (nsip) of the Netscaler resource."
  default = "10.78.225.133"
}

variable "external-ip" {
  description = "The subnet IP (snip) of the Netscaler resource."
  default = "10.78.225.148"
}

variable "external-ip-secondary" {
  description = "The subnet IP (snip) of the Netscaler resource."
  default = "10.78.225.149"
}

variable "internal-ip" {
  description = "The subnet IP (snip) of the Netscaler resource."
  default = "10.78.225.164"
}

variable "internal-ip-secondary" {
  description = "The subnet IP (snip) of the Netscaler resource."
  default = "10.78.225.165"
}


/* variable "dns_server" {
  default = "10.0.0.4"
}
variable "ntp_server" {
  default = "10.0.0.4"
}
variable "ldap_server" {
  default = "10.0.0.4"
}
 */