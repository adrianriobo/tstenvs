variable project              {}
variable image_id             { default = "1a4e8018-ddb2-40f7-b0ea-50f6df1c790f" }
# variable image_id             { default = "6e056717-c384-44e7-9b3c-1d045b93ebb3" }
#TBT 6e056717-c384-44e7-9b3c-1d045b93ebb3 1a4e8018-ddb2-40f7-b0ea-50f6df1c790f d1adc7df-d910-44af-80f9-bd9d6f4214c9
#Tested 40G 6de83e57-9d25-4cb8-b872-c53ef39be3b4
variable image_disk_size      { default = 80 }
variable disk_volume_type     { default = "ceph" }
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
variable domain                {}
variable dc_fixed_ip           {}
variable dc_admin_user         { default = "Admin" }
variable dc_admin_password { 
  default = "redhat20.21" 
  sensitive = true
}
variable domain_users           {}

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

$domainUser = "${var.domain}\${var.dc_admin_user}"
$domainUserPassword = ConvertTo-SecureString ${var.dc_admin_password} -AsPlainText -Force
$domainCredentials = New-Object System.Management.Automation.PSCredential ($domainUser, $domainUserPassword)

$guestUser = "Admin"
$guestUserPassword = ConvertTo-SecureString ${var.local_admin_password} -AsPlainText -Force
$guestCredentials = New-Object System.Management.Automation.PSCredential ($domainUser, $domainUserPassword)

Add-Computer -DomainName ${var.domain} -LocalCredential $guestCredentials -Credential $domainCredentials

# Enable domain users to remote desktop access 
# Need to allow domain users for local remote desktop users
Add-LocalGroupMember -Group 'Remote Desktop Users' -Member ${join(",", formatlist("%s\\%s", var.domain, keys(var.domain_users)))}

# Add domain users to local Administrator group to run crc
Add-LocalGroupMember -Group "Administrators" -Member ${join(",", formatlist("%s\\%s", var.domain, keys(var.domain_users)))}

#Specific to PSI switch ssh 
# Remove cygwin service
C:\cygwin\bin\cygrunsrv --stop sshd
C:\cygwin\bin\cygrunsrv --remove sshd

# PS Core 
$source = 'https://github.com/PowerShell/PowerShell/releases/download/v7.1.3/PowerShell-7.1.3-win-x64.msi'
$destination = 'PowerShell-7.1.3-win-x64.msi'
Invoke-WebRequest -Uri $source -OutFile $destination
msiexec.exe /package $destination /quiet ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1
Remove-Item -Path $destination

# Add ssh server capability
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
#Start-Service sshd
#Set-Service -Name sshd -StartupType 'Automatic'
Set-Content -Path C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\sshd.bat -Value 'powershell -command "sshd"'

New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShellCommandOption -Value "/c" -PropertyType String -Force

# TODO foreach defined domain user
# ForEach ($child in $childs) { $acl = (Get-Acl $child) $acl.SetAccessRule($rule) Set-Acl $child $acl}

# ssh parent folder grant permissions
$sshFolder = 'C:\ProgramData\ssh'
$acl = Get-Acl $sshFolder
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule("crc.testing\crc", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
$acl.SetAccessRule($rule)
Set-Acl $sshFolder $acl
# Use inherit permissions from parent folder
icacls "$sshFolder\*" /q /c /t /reset

# Restart computer
Restart-Computer -Force
USERDATA
}

# Add-Computer -DomainName ${var.domain} -LocalCredential $guestCredentials -Credential $domainCredentials -Restart
# Pre create volume from instance
resource openstack_blockstorage_volume_v3 this {
  name        = "${var.project}-windows10"
  size        = var.image_disk_size
  image_id    = var.image_id
  volume_type = var.disk_volume_type

  timeouts {
    create = "15m"
  }
}

# Wait for dc ready
resource null_resource dc_readiness {
  triggers = {
    dc_readiness = var.dc_readiness
  }
}

# Instance
resource openstack_compute_instance_v2 this {

  # Wait for dc ready as user data will join the domain
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

