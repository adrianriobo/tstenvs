variable private-network-name { default = "ms-corporate" }
variable private-subnet-name { default = "ms-corporate-subnet" }
variable private-subnet-cidr { default = "192.168.199.0/24" }
variable router-name { default = "ms-corporate-router" }
#https://docs.engineering.redhat.com/pages/viewpage.action?pageId=63300728#PSIOpenStackOnboarding-OpenStackNetwork
variable public-network-name { default = "provider_net_shared_3" }
variable dc-image-name { default = "win-2019-serverstandard-x86_64-released_v2" }
variable dc-flavor-name { default = "m1.large" }
variable guest-image-name { default = "Fedora-Cloud-Base-33" } 
variable guest-flavor-name { default = "m1.medium" }
variable flavor-name { default = "m1.medium" }
variable security-groups { 
  type = list(string) 
  default = ["default"] 
}

# Import data from existing resources
data openstack_networking_network_v2 public-network { name = var.public-network-name }

# Import references for persistent components
data openstack_compute_keypair_v2 this { name = "default" }

# Crete networking
resource openstack_networking_network_v2 this {
  name           = var.private-network-name
  admin_state_up = "true"
}

resource openstack_networking_subnet_v2 this {
  name       = var.private-subnet-name 
  network_id = openstack_networking_network_v2.this.id
  cidr       = var.private-subnet-cidr
  ip_version = 4
}

# Link public network with private network
resource openstack_networking_router_v2 this {
  name                = var.router-name
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.public-network.id 
}

resource openstack_networking_router_interface_v2 router_interface_1 {
  router_id = openstack_networking_router_v2.this.id
  subnet_id = openstack_networking_subnet_v2.this.id
}

# Create floating ip 
resource openstack_networking_floatingip_v2 dc {
  pool = var.public-network-name
}

# Create ephemeral resources
resource openstack_compute_instance_v2 dc {

  name              = "dc"
  image_name        = var.dc-image-name
  flavor_name       = var.dc-flavor-name
  key_pair          = data.openstack_compute_keypair_v2.this.name
  security_groups   = var.security-groups
  user_data = <<-EOT
  #ps1
  # Install AD services
  install-windowsfeature AD-Domain-Services
  #https://social.technet.microsoft.com/wiki/contents/articles/52765.windows-server-2019-step-by-step-setup-active-directory-environment-using-powershell.aspx#Step_3_Static_IP
  EOT

  metadata = {
    admin_pass = "redhat"
  }

  network {
    name = var.private-network-name
  }

  depends_on = [
    openstack_networking_router_v2.this,
    openstack_networking_router_interface_v2.router_interface_1
  ]
}

resource openstack_compute_floatingip_associate_v2 this {
  floating_ip = openstack_networking_floatingip_v2.dc.address
  instance_id = openstack_compute_instance_v2.dc.id
  fixed_ip    = openstack_compute_instance_v2.dc.network[0].fixed_ip_v4
}
