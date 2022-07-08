variable project-name       {}
variable key-name           {}
variable aws-region         {}
variable availability-zones {}
variable vpc-subnet-cidr    {}
variable intra-subnet-cidr  {}
variable public-subnet-cidr {}
  
module key {
  source                    = "./../../../../infrastructure/aws/common/keys"

  key_name                  = var.key-name
  aws_region                = var.aws-region
}

module network {
  source                    = "./../../../../infrastructure/aws/common/network"

  aws-region                = var.aws-region
  availability-zones        = var.availability-zones
  project-name              = var.project-name
  vpc-subnet-cidr           = var.vpc-subnet-cidr
  intra-subnet-cidr         = var.intra-subnet-cidr
  public-subnet-cidr        = var.public-subnet-cidr
}

module compute {
  source                    = "./../../../../infrastructure/aws/compute/guests/windows"

  # Check if order for subnets match Az
  # subnet_id                 = module.network.intra_subnets[0]
  subnet_id                 = module.network.public_subnets[0]
  availability_zone         = var.availability-zones[0]
  key_name                  = module.key.key_name
}

# This module create isolated VMs as so only one public ip will be joined
output key_name { value = module.key.key_name }
output key_private { 
  value = module.key.key_private
  sensitive = true  
}
output key_public { 
  value = module.key.key_public  
  sensitive = true
}
output win2019_hyperv_id  { value=module.compute.win2019_hyperv_id }
# output hyperv_subnet_id   { value=module.compute.subnet_id }

# # Configuration on init time with -backend-config
terraform {
  backend "s3" {}
}