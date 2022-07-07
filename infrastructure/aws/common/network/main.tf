variable "aws-region" {}
variable "availability-zones" {}
variable "vpc-subnet-cidr" {}
variable "intra-subnet-cidr" {}
variable "public-subnet-cidr" {}
variable "project-name" {}

module vpc {
  source              = "terraform-aws-modules/vpc/aws"
  version             = "3.14.2"

  name                  = var.project-name
  cidr                  = var.vpc-subnet-cidr
  azs                   = var.availability-zones
  intra_subnets         = var.intra-subnet-cidr
  public_subnets        = var.public-subnet-cidr
  enable_dns_hostnames  = true
  enable_dns_support    = true
  enable_nat_gateway    = false

  tags = {
    Name                = "${var.project-name}-vpc"
    Project					    = var.project-name
  }

  public_subnet_tags = {
    Name                = "${var.project-name}-public"
    Project             = var.project-name
  }

  intra_subnet_tags = {
    Name                = "${var.project-name}-intra"
    Project             = var.project-name
  }
}

output vpc_id                   { value = module.vpc.vpc_id }
output vpc-cidr-block           { value = module.vpc.vpc_cidr_block }
output public_subnets           { value = module.vpc.public_subnets }
output intra_subnets            { value = module.vpc.intra_subnets }
output vpc-security-group       { value = module.vpc.default_security_group_id }
output intra_route_table_ids    { value = module.vpc.intra_route_table_ids }
output public_route_table_ids   { value = module.vpc.public_route_table_ids }
