variable project {}
variable external_network {}
variable private_subnet_cidr { default = "172.16.0.0/24" }
variable static_ips_count { type = number }

# Import external network for external routing
data openstack_networking_network_v2 external_network { name = var.external_network }

# Networking
resource openstack_networking_network_v2 this {
  name           = var.project
  admin_state_up = "true"
}

resource openstack_networking_subnet_v2 this {
  name       = "${var.project}_private" 
  network_id = openstack_networking_network_v2.this.id
  cidr       = var.private_subnet_cidr
  ip_version = 4
}

resource openstack_networking_router_v2 this {
  name                = var.project
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.external_network.id 
}

# Link external router to internal network
resource openstack_networking_router_interface_v2 this {
  router_id = openstack_networking_router_v2.this.id
  subnet_id = openstack_networking_subnet_v2.this.id
}

resource openstack_networking_port_v2 this {
  count = var.static_ips_count

  name           = "fixed_ip_${count.index}"
  network_id     = openstack_networking_network_v2.this.id
  # admin_state_up = false
  admin_state_up = true
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.this.id
  }
}

output network_id           { value = openstack_networking_network_v2.this.id }
output gateway_ip           { value = openstack_networking_subnet_v2.this.gateway_ip }
output static_ips           { value = zipmap( openstack_networking_port_v2.this[*].all_fixed_ips[0], 
                                              openstack_networking_port_v2.this[*].id)}
