variable project_name                   {}
variable aws_region                     {}
# Cost https://aws.amazon.com/ec2/pricing/on-demand/
# Multi instance support https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/dedicated-hosts-overview.html
# https://docs.amazonaws.cn/en_us/AWSEC2/latest/UserGuide/how-dedicated-hosts-work.html#dedicated-hosts-allocating
variable dedicated_type                 { default = "m5n" }
variable instance_type                  {
    type    = map(string)
    default = {
        "m5n" = "m5n.metal"
    }
}
variable vpc_id                         {}
variable vpc_default_security_group_id  {}
variable availability_zone              {}
variable subnet_id                      {}   
variable key_name                       {}
variable root_volume_size               { default = "100"}

# resource aws_ec2_host this {
#   instance_family     = var.dedicated_type
#   availability_zone   = var.availability_zone
# }

module ssh_sg {
  source = "terraform-aws-modules/security-group/aws//modules/ssh"

  name        = "ssh"
  description = "Access with ssh"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
}

module rdp_sg {
  source = "terraform-aws-modules/security-group/aws//modules/rdp"

  name        = "rdp"
  description = "Access with rdp"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
}

resource aws_instance this {
  ami                 = data.aws_ami.win2019_hyperv.id
  instance_type       = var.instance_type[var.dedicated_type]
  # host_id             = aws_ec2_host.this.id
  subnet_id           = var.subnet_id
  # Check AMI with ec2launch-v2
  # user_data     = file("${path.module}/userdata.yaml")
  user_data           = local.windows_setup
  key_name            = var.key_name
  # Security groups
  vpc_security_group_ids = [
    module.ssh_sg.security_group_id, 
    module.rdp_sg.security_group_id,
    var.vpc_default_security_group_id
  ]
  
  root_block_device {
    volume_size     = var.root_volume_size
  }

  tags = {
    Name = "win2019_hyperv-${var.project_name}"
  }
}

output win2019_hyperv_id  { value=data.aws_ami.win2019_hyperv.id }
output instance_public_ip { value=aws_instance.this.public_ip }
