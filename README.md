#Netscaler HA Deployment (netscaler-ha-add)
This module will deploy a Netscaler VPX cluster (two nodes). 

The deployment depresources will be created in a dedicated resource group, but depends on an existing VNET. Network Security Groups are created for each interface. After provisioning both Netscalers are available through a public IP address assigned to the (nsip) Netscaler management address (this should be changed in production).

Usage (sample):

    module "netscaler-ha-add" {
      source      = "./netscaler-core-ha"
      name        = "netscaler-ha"
      environment = "development"
      ..........
    }


## Problems Solved
- Availability set is provisioned.
- Secondary VPX node is provisioned.
- Application Load Balancer w/BackEnd-FrontEnd-Probes-Health configuration is provisioned.
- A DNS record will be created on provisioning (A record).
- Azure SAML details are provided as Terraform output.
- Refactored code to 'nsnode' module.
- Azure Keyvault is now used to store admin password.

## Not yet solved
- Marketplace Terms of use for Netscaler image should be programmatically accepted.
- Azure AD application must be created (currently not possible with terraform service principal (must be Owner or have specific role permissions to add ad apps) 
- Configure netscaler instances with functional ns.conf. 
- Provide Azure signing certificate to netscaler (or location) -> /flash/nsconfig/ssl.
- Create selfsigned certificate to be used for the Netscaler Gateway. (Letsencrypt)

##Modules

* [nsnode](#nsnode)


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| admin\_username | The username associated with the local administrator account on the netscaler | string | `nsadmin` | no |
| dns\_server | - | string | `10.0.0.4` | no |
| dnszone\_resource\_group | The name of the resource group where the DNZ zone exists. | string | `dnb-gf-tf-dns-rg` | no |
| domain | - | string | `tech-01-dev.net` | no |
| external-ip | - | string | `10.78.225.134` | no |
| external-ip-secondary | - | string | `10.78.225.135` | no |
| hostname | - | string | `access-dev` | no |
| internal-ip | - | string | `10.78.225.136` | no |
| internal-ip-secondary | - | string | `10.78.225.137` | no |
| keyvault\_name | - | string | `dnbgftfvault` | no |
| keyvault\_resource\_group\_name | - | string | `dnb-gf-tf-keyvault-rg` | no |
| ldap\_server | - | string | `10.0.0.4` | no |
| location | The region where resources will be provisioned. | string | `northeurope` | no |
| mgmt-domain-label | The DNS label associated to the netscaler management endpoint. | string | `ns-mgmt-dnb` | no |
| mgmt-ip | - | string | `10.78.225.132` | no |
| mgmt-ip-secondary | - | string | `10.78.225.133` | no |
| netscaler\_names | - | list | `<list>` | no |
| ntp\_server | - | string | `10.0.0.4` | no |
| prefix | The prefix used for most resources used, must be an alphanumberic string | string | `netscaler` | no |
| resource\_group | The name of the resource group where resources will be provisioned. | string | `dnb-gf-tf-netscaler-ha-rg` | no |
| vnet | - | string | `dnbgf-exposed-tf-vnet` | no |
| vnet\_resource\_group | The name of the resource group where the resources will be provisioned. | string | `dnb-gf-tf-virtualnetworks-rg` | no |
| vpn-domain-label | The DNS label associated to the netscaler Gateway endpoint. | string | `vpn-dnb` | no |

| Name | Description | Default | Required |
|------|-------------|:-----:|:-----:|
| name | The name of the deployment. | - | yes |
| environment | The type of environment for the deployment. | development | yes |
| location | The location of your deployment. | westeurope | yes |
| resource_group | The name of the resource group where resources will be provisioned. | dnb-gf-tf-netscaler-ha-rg | yes |
| vnet_resource_group | The name of the resource group where the VNET exists. | dnb-gf-tf-virtualnetworks-rg | yes |
| dnszone_resource_group | The name of the resource group where the DNZ zone exists. | dnb-gf-tf-dns-rg | yes |
| hostname | The hostname for the netscaler.  | - | yes |
| prefix | The prefix to use for most resources.  | netscaler | no |
| admin_username | The username to use.  | nsadmin | yes |
| keyvault_name | The name of the existing keyvault to store the user secret. | dnbgftfkeyvault | yes |
| keyvault_resource_group | The name of the resource group where the keyvault exists. | dnb-gf-tf-keyvault-rg | yes |
| vnet | The vnet to use.  | - | yes |
| mgmt_domain_label | The management domain name labe.  | - | no |
| vpn_domain_label | The vpn domain name label.  | - | no |
| mgmt_ip | The ip address of the management interface (nsip).  | - | yes |
| mgmt_ip_secondary | The ip address of the management interface (nsip).   | - | yes |
| external_ip | The ip address of the external interface. | - | yes |
| external_ip_secondary | The ip address of the external interface.  | - | yes |
| internal_ip | The ip address of the internal interface.  | - | yes |
| internal_ip_secondary | The ip address of the internal interface.  | - | yes |
| dns_server | The DNS servers to use.  | - | no |
| ntp_server | The NTP server to use.  | - | no |
| ldap_server | The LDAP server to use.  | - | no |


## Outputs
All outputs are defined in the output.tf file. 

| Name | Description |
|------|-------------|
| idp\_app\_metadata | - |
| ns1\_nsip | - |
| ns1\_nsip\_fqdn | - |
| ns2\_nsip | - |
| ns2\_nsip\_fqdn | - |
| ns\_dns\_server | - |
| ns\_ldap\_server | - |
| ns\_ntp\_server | - |
| ns\_password | ## must be removed |
| ns\_user | - |
| ns\_vpnpip | - |
| saml\_app\_identifier | - |
| saml\_signon\_endpoint | - |
| saml\_signout\_endpoint | - |

#nsnode

The nsnode module creates a single Netscaler virtual machine. 

Usage (sample):

    module "nsnode" {
      name = "netscaler1"
      source = "./nsnode"
      resource_group_name = ""
      availability_set_id = ""
      location = ""
      network_interface_ids = [""]
      primary_network_interface_id = ""
      vm_size = ""
      admin_username = ""
      admin_password = ""
    }


##Inputs
Variables are provided in the `variables.tf` file. Most of these are mandatory, but have default values. 
Single variables in this file can be overrided by using the '--var foo=key' option or another variable file can be used using the '--var-file staging.tfvars' option. 

| Name | Description | Default | Required |
|------|-------------|:-----:|:-----:|
| name | name of the new node | netscaler1 | yes |
| resource_group_namee | The name of the resource group where the node will be provisioned. | - | yes |
| availability_set_id | The availability_set_id. | - | yes |
| location | The name of the location. | - | yes |
| network_interface_ids | The list of interfaces assigned to the vm. | - | yes |
| primary_network_interface_id | The primary interface id. | - | yes |
| vm_size | The vm size to provision. | - | yes |
| admin_username | The name of the admin user. | - | yes |
| admin_password | The password of the admin user. | - | yes |

##Outputs

| Name | Description |
|------|-------------|

 
### Terraform provisioning samples
* `terraform init`
* `terraform plan --out plan.tfplan`
* `terraform plan --out plan.tfplan --var-file staging.tfvars`

* `terraform apply "plan.tfplan" `
* `terraform destroy`  (Note: This will delete all resource)

