module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"

  name = "vpc-${var.project-name}"

  cidr = var.vpc-subnet-cidr

  azs              = var.availability-zones
  private_subnets  = var.private-subnet-cidr
  public_subnets   = var.public-subnet-cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway = true

  tags = {
    Name                                        = "${var.project-name}-vpc"
    Project					= var.project-name
  }

  public_subnet_tags = {
    Name                                        = "${var.project-name}-public"
    Project                                     = var.project-name
  }

  private_subnet_tags = {
    Name                                        = "${var.project-name}-private"
    Project                                     = var.project-name
  }
}
