variable project          {}
variable image_id         { default = "c6d03c06-1bb7-4815-aebd-0d232af5f911" }
variable flavor_name      { default = "ci.nested.m1.large.xdisk.xmem" }
variable fixed_ip_port_id {}
variable dc_fixed_ip      {}
variable external_network {}
variable keypair_name     {}
variable security_groups  { 
  type = list(string) 
  default = ["default"] 
}

variable 

# Domain controller config
locals {
   domain_controller_user_data = <<USERDATA
#ps1
# Change Admin password
$UserAccount = Get-LocalUser -Name "Admin"
$userPassword = ConvertTo-SecureString "redhat20.21" -AsPlainText -Force
$UserAccount | Set-LocalUser -Password $userPassword

Set-DnsClientServerAddress -InterfaceIndex 6 -ServerAddresses ("192.168.199.56")

$domainUser = "crc.testing\Admin"
$domainUserPassword = ConvertTo-SecureString "redhat20.21" -AsPlainText -Force
$domainCredentials = New-Object System.Management.Automation.PSCredential ($domainUser, $domainUserPassword)

$guestUser = "Admin"
$guestUserPassword = ConvertTo-SecureString "redhat" -AsPlainText -Force
$guestCredentials = New-Object System.Management.Automation.PSCredential ($domainUser, $domainUserPassword)

Add-Computer -DomainName "crc.testing" -LocalCredential $guestCredentials -Credential $domainCredentials -Restart
USERDATA
}

# Data
# Import data from existing resources
data openstack_networking_network_v2 public-network { name = var.public-network-name }
# Import references for persistent components
data openstack_compute_keypair_v2 this { name = "default" }

# Networking
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

resource openstack_networking_router_v2 this {
  name                = var.router-name
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.public-network.id 
}

resource openstack_networking_router_interface_v2 router_interface_1 {
  router_id = openstack_networking_router_v2.this.id
  subnet_id = openstack_networking_subnet_v2.this.id
}

# Instances
# primary DC
resource openstack_compute_instance_v2 dc {

  name              = "dc"
  image_name        = var.dc-image-name
  flavor_name       = var.dc-flavor-name
  key_pair          = data.openstack_compute_keypair_v2.this.name
  security_groups   = var.security-groups
  user_data = <<-EOT
  #ps1
  # Change Admin password
  $UserAccount = Get-LocalUser -Name "Admin"
  $userPassword = ConvertTo-SecureString "redhat20.21" -AsPlainText -Force
  $UserAccount | Set-LocalUser -Password $userPassword
  # Install AD feature
  Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
  $safeModePassword = ConvertTo-SecureString "F/@p]*/*D/#2hC.6" -AsPlainText -Force
  # Set up AD Forest
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
  Restart-Computer -Force
  # This should be done after restart
  # # $userPassword = ConvertTo-SecureString "redhat20.21" -AsPlainText -Force
  New-ADUser `
    -SamAccountName "crc-user" `
    -Name "crc" `
    -AccountPassword $userPassword `
    -ChangePasswordAtLogon $False `
    -Enabled $True
  EOT

  network {
    uuid = openstack_networking_network_v2.this.id
    # we need fixed ip to setup the primary DC
    # fixed_ip_v4 = var.dc-fixed-ip
    
  }

  metadata = {
    admin_pass = "redhat"
  }

  depends_on = [
    openstack_networking_router_v2.this,
    openstack_networking_router_interface_v2.router_interface_1
  ]
}

# TODO remove floating for dc as the set up goes through private subnet
resource openstack_networking_floatingip_v2 dc {
  pool = var.public-network-name

  depends_on = [
    openstack_compute_instance_v2.dc,
  ]
}

resource openstack_compute_floatingip_associate_v2 dc {
  floating_ip = openstack_networking_floatingip_v2.dc.address
  instance_id = openstack_compute_instance_v2.dc.id
  fixed_ip    = openstack_compute_instance_v2.dc.network[0].fixed_ip_v4
}

# Guest
resource openstack_compute_instance_v2 guest {

  name              = "guest"
  image_id        = var.guest-image-id
  flavor_name       = var.guest-flavor-name
  key_pair          = data.openstack_compute_keypair_v2.this.name
  security_groups   = var.security-groups
  user_data = <<-EOT
  #ps1
  # Change Admin password
  $UserAccount = Get-LocalUser -Name "Admin"
  $userPassword = ConvertTo-SecureString "redhat20.21" -AsPlainText -Force
  $UserAccount | Set-LocalUser -Password $userPassword

  Set-DnsClientServerAddress -InterfaceIndex 6 -ServerAddresses ("192.168.199.56")

  $domainUser = "crc.testing\Admin"
  $domainUserPassword = ConvertTo-SecureString "redhat20.21" -AsPlainText -Force
  $domainCredentials = New-Object System.Management.Automation.PSCredential ($domainUser, $domainUserPassword)

  $guestUser = "Admin"
  $guestUserPassword = ConvertTo-SecureString "redhat" -AsPlainText -Force
  $guestCredentials = New-Object System.Management.Automation.PSCredential ($domainUser, $domainUserPassword)

  Add-Computer -DomainName "crc.testing" -LocalCredential $guestCredentials -Credential $domainCredentials -Restart 
  EOT

  network {
    uuid = openstack_networking_network_v2.this.id
    # we need fixed ip to setup the primary DC
    # fixed_ip_v4 = var.dc-fixed-ip
  }

  metadata = {
    admin_pass = "redhat"
  }

  depends_on = [
    openstack_networking_router_v2.this,
    openstack_networking_router_interface_v2.router_interface_1
  ]
}

# Create floating ip 
resource openstack_networking_floatingip_v2 guest {
  pool = var.public-network-name

  depends_on = [
    openstack_compute_instance_v2 .guest
  ]
}

resource openstack_compute_floatingip_associate_v2 guest {
  floating_ip = openstack_networking_floatingip_v2.guest.address
  instance_id = openstack_compute_instance_v2.guest.id
  fixed_ip    = openstack_compute_instance_v2.guest.network[0].fixed_ip_v4
}
