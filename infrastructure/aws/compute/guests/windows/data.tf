variable win2019_hyperv_name   { default="Windows_Server-2019-English-Full-HyperV*" }

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

# Join domain
locals {
   windows_setup = <<USERDATA
<powershell>
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Set-Service -Name sshd -StartupType ‘Automatic’
Start-Service sshd
</powershell>
USERDATA
}

# To get subnets based on data, need to split the module creation
# 1 network 2 compute...may we can do it for aggregate env
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
