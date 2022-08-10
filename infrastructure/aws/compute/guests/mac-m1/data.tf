variable macos_version_name           { default="amzn-ec2-macos-12*" }

data aws_ami macos {
  # most_recent = true
  filter {
    name   = "name"
    values = [var.macos_version_name]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["arm64_mac"]
  }
  owners = ["amazon"]
}

# arm64_mac