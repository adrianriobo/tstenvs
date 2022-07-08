# Cost https://aws.amazon.com/ec2/pricing/on-demand/
# Multi instance support https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/dedicated-hosts-overview.html
# https://docs.amazonaws.cn/en_us/AWSEC2/latest/UserGuide/how-dedicated-hosts-work.html#dedicated-hosts-allocating
variable dedicated-type         { default = "m5n" }
variable instance-type          {
    type    = map(string)
    default = {
        "m5n" = "m5n.2xlarge"
    }
}
variable availability_zone      {}
# variable vpc_id              {}
variable subnet_id              {}   
variable key_name               {}

# Add a check for values public or intra
# variable subnet_tier            { default="public" }

resource aws_ec2_host this {
  instance_family     = var.dedicated-type
  availability_zone = var.availability_zone
}

resource aws_instance this {
  ami           = data.aws_ami.win2019_hyperv.id
  instance_type = var.instance-type[var.dedicated-type]
  host_id       = aws_ec2_host.this.id
  subnet_id     = var.subnet_id
  # Check AMI with ec2launch-v2
#   user_data     = file("${path.module}/userdata.yaml")
  user_data     = local.windows_setup
  key_name      = var.key_name

  tags = {
    Name = "test"
  }
}

output win2019_hyperv_id { value=data.aws_ami.win2019_hyperv.id }
# output subnet_id { value=data.aws_subnets.this.ids } 