provider "azurerm" { version = "~> 1.33.0" }

resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group}"
  location = "${var.location}"
}

# resource "azurerm_storage_account" "stor" {
#   name                     = "${var.dns_name}stor"
#   location                 = "${var.location}"
#   resource_group_name      = "${azurerm_resource_group.rg.name}"
#   account_tier             = "${var.storage_account_tier}"
#   account_replication_type = "${var.storage_replication_type}"
# }

resource "azurerm_availability_set" "avset" {
  name                         = "${var.dns_name}avset"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
}

resource "azurerm_public_ip" "lbpip" {
  name                = "${var.ip_name}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  allocation_method   = "Dynamic"
  domain_name_label   = "${var.lb_ip_dns_name}"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.virtual_network_name}"
  location            = "${var.location}"
  address_space       = ["${var.address_space}"]
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.subnet_name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  address_prefix       = "${var.subnet_prefix}"
  service_endpoints    = ["Microsoft.Sql"]
}

resource "azurerm_lb" "lb" {
  resource_group_name = "${azurerm_resource_group.rg.name}"
  name                = "${var.lb_name}"
  location            = "${var.location}"

  frontend_ip_configuration {
    name                 = "LoadBalancerFrontEnd"
    public_ip_address_id = "${azurerm_public_ip.lbpip.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "backend_pool" {
  resource_group_name = "${azurerm_resource_group.rg.name}"
  loadbalancer_id     = "${azurerm_lb.lb.id}"
  name                = "BackendPool1"
}

resource "azurerm_lb_nat_rule" "tcp" {
  resource_group_name            = "${azurerm_resource_group.rg.name}"
  loadbalancer_id                = "${azurerm_lb.lb.id}"
  name                           = "RDP-VM-${count.index}"
  protocol                       = "tcp"
  frontend_port                  = "5000${count.index + 1}"
  backend_port                   = 3389
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  count                          = 2
}

resource "azurerm_lb_rule" "lb_rule" {
  resource_group_name            = "${azurerm_resource_group.rg.name}"
  loadbalancer_id                = "${azurerm_lb.lb.id}"
  name                           = "LBRule"
  protocol                       = "tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  enable_floating_ip             = false
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.backend_pool.id}"
  idle_timeout_in_minutes        = 5
  probe_id                       = "${azurerm_lb_probe.lb_probe.id}"
  depends_on                     = ["azurerm_lb_probe.lb_probe"]
}

resource "azurerm_lb_probe" "lb_probe" {
  resource_group_name = "${azurerm_resource_group.rg.name}"
  loadbalancer_id     = "${azurerm_lb.lb.id}"
  name                = "tcpProbe"
  protocol            = "tcp"
  port                = 80
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource "azurerm_network_interface" "nic" {
  name                = "nic${count.index}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  count               = 2

  ip_configuration {
    name                                    = "ipconfig${count.index}"
    subnet_id                               = "${azurerm_subnet.subnet.id}"
    private_ip_address_allocation           = "Dynamic"
    load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.backend_pool.id}"]
    load_balancer_inbound_nat_rules_ids     = ["${element(azurerm_lb_nat_rule.tcp.*.id, count.index)}"]
  }
}

resource "azurerm_virtual_machine" "vm" {
  name                  = "VM${count.index}"
  location              = "${var.location}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  availability_set_id   = "${azurerm_availability_set.avset.id}"
  vm_size               = "${var.vm_size}"
  network_interface_ids = ["${element(azurerm_network_interface.nic.*.id, count.index)}"]
  count                 = 2

  storage_image_reference {
    publisher = "${var.image_publisher}"
    offer     = "${var.image_offer}"
    sku       = "${var.image_sku}"
    version   = "${var.image_version}"
  }

  storage_os_disk {
    name          = "osdisk${count.index}"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "${var.hostname}"
    admin_username = "${var.VM_admin_username}"
    admin_password = "${var.VM_admin_password}"
  }

  os_profile_windows_config {}
}

resource "azurerm_mariadb_server" "maria_db_server" {
  name                = "${var.server_name}"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  sku {
    name     = "${var.server_sku_name}"
    capacity = "${var.server_sku_capacity}"
    tier     = "${var.server_sku_tier}"
    family   = "${var.server_sku_family}"
  }

  storage_profile {
    storage_mb            = "${var.server_storage_mb}"
  }

  administrator_login          = "${var.server_login}"
  administrator_login_password = "${var.server_password}"
  version                      = "${var.server_version}"
  ssl_enforcement              = "${var.server_ssl_enforcement}"
}
resource "azurerm_mariadb_virtual_network_rule" "test" {
  name                = "${var.vnet_rule_name}"
  resource_group_name = "${var.resource_group}"
  server_name         = "${azurerm_mariadb_server.maria_db_server.name}"
  subnet_id           = "${azurerm_subnet.subnet.id}"
}

# data "azurerm_public_ip" "test" {
#   name                = "${azurerm_public_ip.lbpip.name}"
#   resource_group_name = "${var.resource_group}"
# }
# resource "azurerm_mariadb_firewall_rule" "test" {
#   name                = "${var.firewall_rule}"
#   resource_group_name = "${var.resource_group}"
#   server_name         = "${azurerm_mariadb_server.maria_db_server.name}"
#   start_ip_address    = "${data.azurerm_public_ip.test.ip_address}"
#   end_ip_address      = "${data.azurerm_public_ip.test.ip_address}"
# }
resource "azurerm_mariadb_database" "maria_db" {
  name                = "${var.database_name}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  server_name         = "${azurerm_mariadb_server.maria_db_server.name}"
  charset             = "${var.database_utf_charset}"
  collation           = "${var.database_collation}"
}


