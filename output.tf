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

/* output "ns_dns_server" {
  value ="${var.dns_server}"
}

output "ns_ldap_server" {
  value ="${var.ldap_server}"
}

output "ns_ntp_server" {
  value ="${var.ntp_server}"
}
 */
/* output "saml_idp_signingcert" {
  type= "string"
  value = ""
} */

/* output "saml_signon_endpoint" {
  value = "https://login.microsoftonline.com/7f73ddb0-b379-4171-9354-f82e3068e25a/saml2"
}
output "saml_signout_endpoint" {
  value = "https://login.microsoftonline.com/7f73ddb0-b379-4171-9354-f82e3068e25a/saml2"
}

output "saml_app_identifier" {
  value = "https://access.tech-01-dev.net/"
}

output "idp_app_metadata" {
  value = "https://login.microsoftonline.com/7f73ddb0-b379-4171-9354-f82e3068e25a/federationmetadata/2007-06/federationmetadata.xml?appid=d360cd8e-8c81-4d0c-8085-ea7352c7fe0a"
}
 */
 