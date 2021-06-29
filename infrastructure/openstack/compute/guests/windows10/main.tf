variable project              {}
# variable image_id             { default = "c6d03c06-1bb7-4815-aebd-0d232af5f911" }
variable image_id             { default = "6de83e57-9d25-4cb8-b872-c53ef39be3b4" }
variable image_disk_size      { default = 80 }
variable flavor_name          { default = "ci.nested.m1.large.xdisk.xmem" }
variable fixed_ip_port_id     {}
variable fixed_ip             {}
variable keypair_name         {}
variable security_groups      { default = ["default"] }
variable local_admin_password { 
  default = "redhat20.21" 
  sensitive = true
}
variable dc_readiness          { description = "ensures dc is properly setup"}
variable dc_domain             { default = "crc.testing" }
variable dc_fixed_ip           {}
variable dc_admin_user         { default = "Admin" }
variable dc_admin_password { 
  default = "redhat20.21" 
  sensitive = true
}

variable external_network       {}

# Join domain
locals {
   domain_member_user_data = <<USERDATA
#ps1

# Change Admin password
$UserAccount = Get-LocalUser -Name "Admin"
$userPassword = ConvertTo-SecureString ${var.local_admin_password} -AsPlainText -Force
$UserAccount | Set-LocalUser -Password $userPassword

Set-DnsClientServerAddress -InterfaceIndex (Get-NetAdapter -Physical).InterfaceIndex -ServerAddresses ("${var.dc_fixed_ip}")

$domainUser = "${var.dc_domain}\${var.dc_admin_user}"
$domainUserPassword = ConvertTo-SecureString ${var.dc_admin_password} -AsPlainText -Force
$domainCredentials = New-Object System.Management.Automation.PSCredential ($domainUser, $domainUserPassword)

$guestUser = "Admin"
$guestUserPassword = ConvertTo-SecureString ${var.local_admin_password} -AsPlainText -Force
$guestCredentials = New-Object System.Management.Automation.PSCredential ($domainUser, $domainUserPassword)

Add-Computer -DomainName ${var.dc_domain} -LocalCredential $guestCredentials -Credential $domainCredentials

#Specific to PSI switch ssh 
# Remove cygwin service
C:\cygwin\bin\cygrunsrv --stop sshd
C:\cygwin\bin\cygrunsrv --remove sshd

# Add ssh server capability
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'

# Restart computer
Restart-Computer -Force
USERDATA
}

# Add-Computer -DomainName ${var.dc_domain} -LocalCredential $guestCredentials -Credential $domainCredentials -Restart
# Pre create volume from instance
resource openstack_blockstorage_volume_v3 this {
  name        = "${var.project}-windows10"
  size        = var.image_disk_size
  image_id    = var.image_id

  timeouts {
    create = "15m"
  }
}

# # Wait for dc ready
resource null_resource dc_readiness {
  triggers {
    dependency_id = var.dc_readiness
  }
}

# Instance
resource openstack_compute_instance_v2 this {

  # # Wait for dc ready as user data will join the domain
  depends_on = [
    null_resource.dc_readiness
  ]

  name              = "${var.project}-windows10"
  flavor_name       = var.flavor_name
  key_pair          = var.keypair_name
  security_groups   = var.security_groups
  user_data         = local.domain_member_user_data

  block_device {
    uuid                  = openstack_blockstorage_volume_v3.this.id
    source_type           = "volume"
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  network_mode = "none"

  metadata = {
    admin_pass = "redhat"
  }
}

resource openstack_compute_interface_attach_v2 this {
  instance_id = openstack_compute_instance_v2.this.id
  port_id     = var.fixed_ip_port_id

  depends_on = [
    openstack_compute_instance_v2.this
  ]
}

resource openstack_networking_floatingip_v2 this {
  pool = var.external_network
}

resource openstack_compute_floatingip_associate_v2 this {
  floating_ip = openstack_networking_floatingip_v2.this.address
  instance_id = openstack_compute_instance_v2.this.id

  depends_on = [
    openstack_compute_interface_attach_v2.this
  ]
}

output public_ip  { value = openstack_networking_floatingip_v2.this.address }
output private_ip { value = var.fixed_ip }

