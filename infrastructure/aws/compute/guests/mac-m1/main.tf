variable project_name                   {}
variable aws_region                     {}
variable dedicated_type                 { default = "mac2.metal" }
variable vpc_id                         {}
variable vpc_default_security_group_id  {}
variable availability_zone              {}
variable subnet_id                      {}   
variable key_name                       {}
variable root_volume_size               { default = "100"}

resource aws_ec2_host this {
  instance_type     = var.dedicated_type
  availability_zone   = var.availability_zone
  auto_placement      = "off"
}

module ssh_sg {
  source = "terraform-aws-modules/security-group/aws//modules/ssh"

  name        = "ssh"
  description = "Access with ssh"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
}

resource aws_instance this {
  ami                 = data.aws_ami.macos.id
  instance_type       = var.dedicated_type
  host_id             = aws_ec2_host.this.id
  subnet_id           = var.subnet_id
  key_name            = var.key_name
  # Security groups
  vpc_security_group_ids = [
    module.ssh_sg.security_group_id, 
    var.vpc_default_security_group_id
  ]
  
  root_block_device {
    volume_size     = var.root_volume_size
  }

  tags = {
    Name = "mac-m1-${var.project_name}"
  }
}

output macos_version_id  { value=data.aws_ami.macos.id }
output instance_public_ip { value=aws_instance.this.public_ip }
