# Import data from existing resources
data openstack_networking_network_v2 public-network { name = var.public-network-name }

# Import references for persistent components
data openstack_compute_keypair_v2 this { name = "default" }

# Crete networking
resource openstack_networking_network_v2 this {
  name           = var.network-name
  admin_state_up = "true"
}

resource openstack_networking_subnet_v2 this {
  name       = "${var.network-name}-private" 
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
  Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
  $safeModePassword = ConvertTo-SecureString "F/@p]*/*D/#2hC.6" -AsPlainText -Force
  Install-ADDSForest `
    -DomainName "crc.testing" `
    -CreateDnsDelegation:$false `
    -DatabasePath "C:\Windows\NTDS" `
    -DomainMode "7" `
    -DomainNetbiosName "crc" `
    -ForestMode "7" `
    -InstallDns:$true `
    -LogPath "C:\Windows\NTDS" `
    -NoRebootOnCompletion:$True `
    -SysvolPath "C:\Windows\SYSVOL" `
    -Force:$true `
    -SafeModeAdministratorPassword $safeModePassword
  Restart-Computer
  # This should be done after restart
  # $userPassword = ConvertTo-SecureString "redhat20.21" -AsPlainText -Force
  # New-ADUser `
  #   -SamAccountName "crc-user" `
  #   -Name "crc" `
  #   -AccountPassword $userPassword `
  #   -ChangePasswordAtLogon $False `
  #   -Enabled $True
  EOT

  metadata = {
    admin_pass = "redhat"
  }

  network {
    uuid = openstack_networking_network_v2.this.id
    # we need fixed ip to setup the primary DC
    fixed_ip_v4 = var.dc-fixed-ip
    
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
