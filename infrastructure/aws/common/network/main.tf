variable project_name       {}
variable aws_region         {}
variable availability_zones {}
variable vpc_subnet_cidr    {}
variable intra_subnet_cidr  {}
variable public_subnet_cidr {}

module vpc {
  source              = "terraform-aws-modules/vpc/aws"
  version             = "3.14.2"

  name                  = var.project_name
  cidr                  = var.vpc_subnet_cidr
  azs                   = var.availability_zones
  intra_subnets         = var.intra_subnet_cidr
  public_subnets        = var.public_subnet_cidr
  enable_dns_hostnames  = true
  enable_dns_support    = true
  enable_nat_gateway    = false

  tags = {
    Name                = "${var.project_name}-vpc"
    Project					    = var.project_name
  }

  public_subnet_tags = {
    Name                = "${var.project_name}-public"
    Project             = var.project_name
    Tier                = "public"
  }

  intra_subnet_tags = {
    Name                = "${var.project_name}-intra"
    Project             = var.project_name
    Tier                = "intra"
  }
}

output vpc_id                         { value = module.vpc.vpc_id }
output vpc_cidr_block                 { value = module.vpc.vpc_cidr_block }
output public_subnets                 { value = module.vpc.public_subnets }
output intra_subnets                  { value = module.vpc.intra_subnets }
output vpc_security_group             { value = module.vpc.default_security_group_id }
output intra_route_table_ids          { value = module.vpc.intra_route_table_ids }
output public_route_table_ids         { value = module.vpc.public_route_table_ids }
output vpc_default_security_group_id  { value = module.vpc.default_security_group_id }

