resource "azurerm_virtual_machine" "main" {
  name                             = "${var.name}"
  availability_set_id              = "${var.availability_set_id}"
  location                         = "${var.location}"
  resource_group_name              = "${var.resource_group_name}"
  network_interface_ids            = ["${var.network_interface_ids}"]
  primary_network_interface_id     = "${var.primary_network_interface_id}"
  vm_size                          = "${var.vm_size}"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = false

  plan {
    name      = "netscaler10standard"
    publisher = "citrix"
    product   = "netscalervpx-121"
  }

  storage_image_reference {
    publisher   = "citrix"
    offer       = "netscalervpx-121"
    sku         = "netscaler10standard"
    version     = "latest"
  }

  storage_os_disk {
    name              = "${var.name}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    disk_size_gb      = "40"
   
  }

  os_profile {
    computer_name  = "${var.name}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
	}

  os_profile_linux_config {
    disable_password_authentication = false
  }

  //boot_diagnostics {
  //  enabled = true
  //  storage_uri = "${var.diag_storage_primary_blob_endpoint}"
  // }

  tags = "${var.common_tags}"
}
