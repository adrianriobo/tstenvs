variable project-name       {}
variable key-name           {}
variable aws-region         {}
variable availability-zones {}
variable vpc-subnet-cidr    {}
variable intra-subnet-cidr  {}
variable public-subnet-cidr {}
  
module key {
  source                    = "./../../../../infrastructure/aws/common/keys"

  key-name                  = var.key-name
  aws-region                = var.aws-region
}

module "network" {
  source                    = "./../../../../infrastructure/aws/common/network"

  aws-region                = var.aws-region
  availability-zones        = var.availability-zones
  project-name              = var.project-name
  vpc-subnet-cidr           = var.vpc-subnet-cidr
  intra-subnet-cidr         = var.intra-subnet-cidr
  public-subnet-cidr        = var.public-subnet-cidr
}

# This module create isolated VMs as so only one public ip will be joined
output key-name { value = module.key.key-name }
output key-private { 
  value = module.key.key-private
  sensitive = true  
}
output key-public { 
  value = module.key.key-public  
  sensitive = true
}

# # Configuration on init time with -backend-config
terraform {
  backend "s3" {}
}