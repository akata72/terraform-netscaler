# Create the Application Load Balancer (public) 
resource "azurerm_lb" "main" {
  name                = "${var.name}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  tags = "${var.common_tags}"
  
# This will be the entrypoint for the VPN server
  frontend_ip_configuration {
    name                 = "FrontEnd"
    public_ip_address_id = "${var.frontend_ip_id}"
  }
}

resource "azurerm_lb_backend_address_pool" "main" {
    name                  = "BackEndAddressPool"
    resource_group_name   = "${var.resource_group_name}"
    loadbalancer_id       = "${azurerm_lb.main.id}"
}

resource "azurerm_network_interface_backend_address_pool_association" "be_pool1" {
  network_interface_id = "${var.network_interface_ids[0]}"
  ip_configuration_name = "external-ip"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.main.id}"
}

resource "azurerm_network_interface_backend_address_pool_association" "be_pool2" {
  network_interface_id = "${var.network_interface_ids[1]}" 
  ip_configuration_name = "external-ip"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.main.id}"
}

resource "azurerm_lb_probe" "main" {
     name                 = "NetscalerProbe"
     port                 = 9000
     protocol             = "TCP"
     interval_in_seconds  = 5
     resource_group_name  = "${var.resource_group_name}"
     loadbalancer_id      = "${azurerm_lb.main.id}" 
}

resource "azurerm_lb_rule" "https" {
    resource_group_name            = "${var.resource_group_name}"
    loadbalancer_id                = "${azurerm_lb.main.id}"
    name                           = "LoadBalancingRule-Https"
    protocol                       = "Tcp"
    frontend_port                  = 443
    backend_port                   = 443
    frontend_ip_configuration_name = "FrontEnd"
    probe_id                       = "${azurerm_lb_probe.main.id}"
    backend_address_pool_id        = "${azurerm_lb_backend_address_pool.main.id}"
    enable_floating_ip             = "true"
}

resource "azurerm_lb_rule" "http" {
    resource_group_name            = "${var.resource_group_name}"
    loadbalancer_id                = "${azurerm_lb.main.id}"
    name                           = "LoadBalancingRule-Http"
    protocol                       = "Tcp"
    frontend_port                  = 80
    backend_port                   = 80
    frontend_ip_configuration_name = "FrontEnd"
    probe_id                       = "${azurerm_lb_probe.main.id}"
    backend_address_pool_id        = "${azurerm_lb_backend_address_pool.main.id}"
    enable_floating_ip             = "true"
}