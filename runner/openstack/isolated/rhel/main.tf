variable project             {}
variable rhel_major          { description = "major version of rhel to pick the right module" }
variable rhel_version        {}
variable rh_user             { default = "no-need-used-for-destroy" }
variable rh_password         { default = "no-need-used-for-destroy" }
  
module networking {
  source                = "./../../../../infrastructure/openstack/networking"

  project               = var.project
}

module common {
  source                = "./../../../../infrastructure/openstack/compute/common"

  project               = var.project
}

module rhel8 {
  source                = "./../../../../infrastructure/openstack/compute/guests/rhel/8"
  depends_on            = [module.networking]
  count                 = var.rhel_major == "8" ? 1 : 0

  project               = var.project
  private_network       = var.project
  keypair_name          = module.common.keypair_name
  rh_user               = var.rh_user
  rh_password           = var.rh_password
  rhel_version          = var.rhel_version
}

module rhel9 {
  source                = "./../../../../infrastructure/openstack/compute/guests/rhel/9"
  depends_on            = [module.networking]
  count                 = var.rhel_major == "9" ? 1 : 0

  project               = var.project
  private_network       = var.project
  keypair_name          = module.common.keypair_name
  rh_user               = var.rh_user
  rh_password           = var.rh_password
  rhel_version          = var.rhel_version
}

# This module create isolated VMs as so only one public ip will be joined
output public_ip { value = join("", [join("", module.rhel8[*].public_ip), join("", module.rhel9[*].public_ip)])  }