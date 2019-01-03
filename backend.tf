########## BACKEND ##########

# We can not use interpolations in this config. Alternative is to use -backend-config in terraform command-line.
terraform {
  backend "azurerm" {
    storage_account_name = "dnbgftfstorageaccount"
    container_name       = "tfstateservices"
    key                  = "terraform.state.netscaler-ha-multinic"
    # need to figure out an alternative way of providing the access_key...
    access_key           = ""
  }
} 
