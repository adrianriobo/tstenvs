variable project_name       {}
variable key_name           {}
variable aws_region         {}
variable availability_zones {}
variable vpc_subnet_cidr    {}
variable intra_subnet_cidr  {}
variable public_subnet_cidr {}
  
module key {
  source                        = "./../../../../infrastructure/aws/common/keys"

  key_name                      = var.key_name
  aws_region                    = var.aws_region
}

module network {
  source                        = "./../../../../infrastructure/aws/common/network"

  project_name                  = var.project_name
  aws_region                    = var.aws_region
  availability_zones            = var.availability_zones
  vpc_subnet_cidr               = var.vpc_subnet_cidr
  intra_subnet_cidr             = var.intra_subnet_cidr
  public_subnet_cidr            = var.public_subnet_cidr
}

module compute {
  source                        = "./../../../../infrastructure/aws/compute/guests/windows"

  # Check if order for subnets match Az
  # subnet_id                 = module.network.intra_subnets[0]
  project_name                  = var.project_name
  aws_region                    = var.aws_region
  vpc_id                        = module.network.vpc_id
  vpc_default_security_group_id = module.network.vpc_default_security_group_id
  subnet_id                     = module.network.public_subnets[0]
  availability_zone             = var.availability_zones[0]
  key_name                      = module.key.key_name
  key_public                    = module.key.key_public
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
output hyperv_id        { value=module.compute.win2019_hyperv_id }
output hyperv_public_ip { value=module.compute.instance_public_ip }
output hyperv_username  { value=module.compute.hyperv_username }
output hyperv_password  { 
  value=module.compute.hyperv_password
  sensitive = true 
}

# # Configuration on init time with -backend-config
terraform {
  backend "s3" {}
}