variable project             {}
variable rhel_version        { description = "RHEL version format: RHEL-9.0.0-20210729.2" }
variable repo_baseos_url     { description = "url for baseos repo"}
variable repo_appstream_url  { description = "url for appstream repo"}
variable rh_user             { description = "rh account username to subscribe"}
variable rh_password         { description = "rh account password to subscribe"}
  
module networking {
  source                = "./../../../../infrastructure/openstack/networking"

  project               = var.project
}

module common {
  source                = "./../../../../infrastructure/openstack/compute/common"

  project               = var.project
}

module rhel {
  source                = "./../../../../infrastructure/openstack/compute/guests/rhel"
  depends_on            = [module.networking]

  project               = var.project
  private_network       = var.project
  keypair_name          = module.common.keypair_name
  rhel_version          = var.rhel_version
  repo_baseos_url       = var.repo_baseos_url
  repo_appstream_url    = var.repo_appstream_url
  rh_user               = var.rh_user
  rh_password           = var.rh_password
  
}

# This module create isolated VMs as so only one public ip will be joined
output public_ip { value = module.rhel.public_ip  }