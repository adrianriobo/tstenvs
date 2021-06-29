variable project          {}
variable image_name       { default = "win-2019-serverstandard-x86_64-released_v2" }
variable flavor_name      { default = "m1.large" }
variable fixed_ip         {}
variable fixed_ip_port_id {}
variable gateway_ip       {}
variable external_network {}
variable keypair_name     {}
variable security_groups  { 
  type = list(string) 
  default = ["default"] 
}
variable dc_local_admin_password  { 
  default = "redhat20.21" 
  sensitive = true
}
variable dc_safemode_password     { 
  default = "F/@p]*/*D/#2hC.6" 
  sensitive = true
}
variable dc_domain                { default = "crc.testing" }
variable dc_users                 { default = {"crc":"redhat20.21"} }


# Domain controller config
locals {
   domain_controller_user_data = <<USERDATA
#ps1

# Change Admin password
$userPassword = ConvertTo-SecureString ${var.dc_local_admin_password} -AsPlainText -Force
$UserAdminAccount = Get-LocalUser -Name "Admin"
$UserAdminAccount | Set-LocalUser -Password $userPassword
$UserAdministratorAccount = Get-LocalUser -Name "Administrator"
$UserAdministratorAccount | Set-LocalUser -Password $userPassword

# Fixed ip
# New-NetIPAddress -InterfaceAlias (Get-NetAdapter).InterfaceAlias -IpAddress ${var.fixed_ip} -AddressFamily IPv4 -Prefixlength 24 -DefaultGateway ${var.gateway_ip}
# Set-DnsClientServerAddress -InterfaceIndex (Get-NetAdapter).InterfaceIndex -ServerAddresses ("${var.fixed_ip}")

# Install AD feature
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
$safeModePassword = ConvertTo-SecureString ${var.dc_safemode_password} -AsPlainText -Force

# Set up AD Forest
Install-ADDSForest `
  -DomainName ${var.dc_domain} `
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

resource openstack_compute_instance_v2 this {
  name              = "${var.project}-dc"
  image_name        = var.image_name
  flavor_name       = var.flavor_name
  key_pair          = var.keypair_name
  security_groups   = var.security_groups
  user_data         = local.domain_controller_user_data

  network_mode = "none"

  # Due to no connectivity during start ?
  metadata = {
    admin_pass = "redhat"
  }
}

resource openstack_compute_interface_attach_v2 this {
  instance_id = openstack_compute_instance_v2.this.id
  port_id     = var.fixed_ip_port_id
}

# TODO remove floating for dc as the set up goes through private subnet
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

# Wait for domain controller set up properly
resource null_resource dc_check {
  depends_on = [
    openstack_compute_floatingip_associate_v2.this 
  ]

  provisioner "local-exec" {
    command =<<DC_CHECK
#!/bin/bash
ready=1
state="Stopped"
while [[ $ready -gt 0 || $state != "Running" ]]
do
    echo "Checking adws service on ${openstack_networking_floatingip_v2.this.address}"
    sshpass -p ${var.dc_local_admin_password} \
      ssh -q -o StrictHostKeyChecking=no \
          -o UserKnownHostsFile=/dev/null \
          Admin@${openstack_networking_floatingip_v2.this.address} exit
    ready=$?
    if [[ $ready -eq 0 ]]; then
        state=$(sshpass -p ${var.dc_local_admin_password} \
                  ssh -q -o StrictHostKeyChecking=no \
                      -o UserKnownHostsFile=/dev/null \
                      Admin@${openstack_networking_floatingip_v2.this.address} \
                      'powershell.exe -command "Get-Service -Name adws | Select-Object Status -ExpandProperty Status"' \
                | cut -c 1-7)
    fi
done
echo "adws service setup OK"
    DC_CHECK
  }
}

# Add users to DC
resource null_resource add_dc_users {
  depends_on = [
    null_resource.dc_check 
  ]

  connection {
    type              = "ssh"
    user              = "Admin"
    password          = var.dc_local_admin_password
    host              = openstack_networking_floatingip_v2.this.address
    target_platform   = "windows"
  }

  # Create ps1 script to add config AD users from var
  provisioner "file" {
    destination = "C:/Users/Admin/add_dc_users.ps1"
    content = templatefile("${path.module}/templates/add_dc_users.ps1.tpl", 
                          { users = var.dc_users})
  }

  # Run powershell script to add dc users and remove temporary file
  provisioner "remote-exec" {
    inline = [
      "powershell.exe -F C:\\Users\\Admin\\add_dc_users.ps1",
      "del C:\\Users\\Admin\\add_dc_users.ps1"]
  }
}

output public_ip    { value = openstack_networking_floatingip_v2.this.address }
output private_ip   { value = var.fixed_ip }
output dc_readiness { value = null_resource.dc_check.id }
