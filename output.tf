########## OUTPUT ##########

output "netscaler1_mgmt_ip" {
  value = "${azurerm_public_ip.vpx1.ip_address}"
}
output "netscaler2_mgmt_ip" {
  value = "${azurerm_public_ip.vpx2.ip_address}"
}

output "netscaler1_mgmt_fqdn" {
  value = "https://${var.prefix}1.${var.domain}"
}

output "netscaler2_mgmt_fqdn" {
  value = "https://${var.prefix}2.${var.domain}"

} 

output "sslvpn_ip" {
  value = "${azurerm_public_ip.vpn.ip_address}"
}

output "sslvpn_fqdn" {
  value = "https://${var.netscalergw}.${var.domain}"
}



### Can potentially be removed in production. Get password from keyvault.
output "password" {
  value ="${random_string.password.result}"
}

output "username" {
  value ="${var.admin_username}"
}

 
