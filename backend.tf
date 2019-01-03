########## BACKEND ##########

# We can not use interpolations in this config. Alternative is to use -backend-config in terraform command-line.
terraform {
  backend "azurerm" {
    storage_account_name = "dnbgftfstorageaccount"
    container_name       = "tfstateservices"
    key                  = "terraform.state.netscaler-ha-multinic"
    # need to figure out an alternative way of providing the access_key...
    access_key           = "rcJIpwd/SmbY6WC0zgsYUv7Krhfa/0wS0B18x6mbeURnr30xQ5CCZIFxGzFZ1CA0K64aywekXSRw9L+7Yn1HoA=="
  }
} 