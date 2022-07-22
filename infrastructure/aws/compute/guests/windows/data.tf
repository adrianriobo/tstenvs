variable win2019_hyperv_name      { default="Windows_Server-2019-English-Full-HyperV*" }
variable hyperv_username          { default = "cloud-user"}
variable key_public               {}

resource random_password hyperv_password {
  length           = 16
  special          = true
  override_special = "!#%&*()-_=+[]{}<>.?"
}

data aws_ami win2019_hyperv {
  most_recent = true
  filter {
    name   = "name"
    values = [var.win2019_hyperv_name]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["amazon"]
}

# Setup ssh and basic config for user
# Also inclusion on Hyper-v Administrator group should be handle by OpenshiftLocal msi 
# but due to a bug it is not...we added to avoid 2 reboots 
# Set-Service -Name sshd -StartupType ‘Automatic’
# #Start-Service sshd
locals {
   windows_setup = <<USERDATA
<powershell>
# Create local user
$Password = ConvertTo-SecureString "${random_password.hyperv_password.result}" -AsPlainText -Force
New-LocalUser ${var.hyperv_username} -Password $Password 
# Run a process with new local user to create profile, so it will create home folder
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ${var.hyperv_username}, $Password
Start-Process cmd /c -WindowStyle Hidden -Wait -Credential $credential -ErrorAction SilentlyContinue
# Add user to required groups
Add-LocalGroupMember -Group "Administrators" -Member ${var.hyperv_username}
# Check if this speed insall of crc...if msi installer checks if no reboot required
Add-LocalGroupMember -Group "Hyper-V Administrators" -Member ${var.hyperv_username}
# Set autologon to user to allow start sshd for the user 
# Check requirements for domain user
# https://docs.microsoft.com/en-us/troubleshoot/windows-server/user-profiles-and-logon/turn-on-automatic-logon
$RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
Set-ItemProperty $RegistryPath 'AutoAdminLogon' -Value "1" -Type String 
Set-ItemProperty $RegistryPath 'DefaultUsername' -Value "${var.hyperv_username}" -type String 
Set-ItemProperty $RegistryPath 'DefaultPassword' -Value "${random_password.hyperv_password.result}" -type String
# Install sshd
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Set-Service -Name sshd -StartupType 'Manual'
# This generate ssh certs + config file for us
Start-Service sshd
# Disable the service as need to start it as a user process on startup
Stop-Service sshd
# Add pub key for the user as authorized_key 
New-Item -Path "C:\Users\${var.hyperv_username}\.ssh" -ItemType Directory -Force
New-Item -Path C:\Users\${var.hyperv_username}\.ssh -Name "authorized_keys" -ItemType "file" -Value "${var.key_public}"
# Set permissions valid permissions for hyper_user on authorized_keys + host_keys
$acl = Get-Acl C:\Users\${var.hyperv_username}\.ssh\authorized_keys
$acl.SetOwner([System.Security.Principal.NTAccount] "${var.hyperv_username}")
$acl.SetAccessRuleProtection($True, $False)
$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule([System.Security.Principal.NTAccount] "${var.hyperv_username}","FullControl","Allow")
$acl.SetAccessRule($AccessRule)
Set-Acl C:\Users\${var.hyperv_username}\.ssh\authorized_keys $acl
Set-Acl -Path "C:\ProgramData\ssh\*key" $acl
# Create bat script to start sshd as a user process on startup
New-Item -Path "C:\Users\${var.hyperv_username}\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup" -Name start-openssh.bat -ItemType "file" -Value 'powershell -command "sshd -f C:\ProgramData\ssh\sshd_config"'
</powershell>
USERDATA
}

# To get subnets based on data, need to split the module creation
# 1 network 2 compute...may we can do it for aggregate env
# Add a check for values public or intra
# variable vpc_id              {}
# variable subnet_tier            { default="public" }
# data aws_subnets this {
#   filter {
#     name   = "vpc-id"
#     values = [var.vpc_id]
#   }
#   filter {
#     name   = "availability-zone"
#     values = [var.availability_zone]
#   }
#   tags = {
#     Tier = var.subnet_tier
#   }
# }
# output subnet_id { value=data.aws_subnets.this.ids } 
output hyperv_username { value=var.hyperv_username }
output hyperv_password { value=random_password.hyperv_password.result }

