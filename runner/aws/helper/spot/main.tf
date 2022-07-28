variable aws_region             { default = "us-east-1" } 
variable instance_type          { default = "m5n.metal" }
variable product_description    { default = "Windows" }

data aws_availability_zones available {
  state = "available"
}

data aws_ec2_instance_type_offerings available {
  for_each          = toset(data.aws_availability_zones.available.names)

  filter {
    name   = "instance-type"
    values = [var.instance_type]
  }
  filter {
    name   = "location"
    values = [each.key]
  }
  location_type = "availability-zone"
}

data aws_ec2_spot_price this {
  # https://github.com/hashicorp/terraform-provider-aws/issues/17446
  # https://github.com/fivexl/terraform-aws-ec2-spot-price/issues/4#issuecomment-1064223240
  # for_each          = toset(slice(data.aws_availability_zones.available.names,0,2))
  for_each          = toset(flatten([for item in data.aws_ec2_instance_type_offerings.available : item.locations]))
  availability_zone = each.key
  instance_type     = var.instance_type
  filter {
    name   = "product-description"
    values = [var.product_description]
  }
}

locals {
  price_per_az = {for k, item in data.aws_ec2_spot_price.this : k => tonumber(format("%f", item.spot_price))}
  price_min = min([for item in data.aws_ec2_spot_price.this : item.spot_price]...)
  az = [for k,v in local.price_per_az : k if v == local.price_min][0]
}

output region             { value=data.aws_availability_zones.available.id }
output price_per_az       { value = local.price_per_az}
output best_price         { value = local.price_min}
output best_az            { value = local.az }