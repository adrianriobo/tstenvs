variable project             {}
variable rhel_version        { default = "" }
variable flavor_name         { default = "ci.nested.virt.m4.xlarge.xmem" }
variable repo_baseos_url     { default = "" }
variable repo_appstream_url  { default = "" }
variable rh_user             { default = "" }
variable rh_password         { default = "" }
variable image_id            { default = "" }
  
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
  flavor_name           = var.flavor_name
  repo_baseos_url       = var.repo_baseos_url
  repo_appstream_url    = var.repo_appstream_url
  rh_user               = var.rh_user
  rh_password           = var.rh_password
  image_id              = var.image_id
}

# This module create isolated VMs as so only one public ip will be joined
output public_ip { value = module.rhel.public_ip  }