variable project             {}
variable rhel_version        { default = "RHEL-8.4.0-x86_64-production-latest"}
variable flavor_name         { default = "ci.nested.virt.m4.xlarge.xmem" }
variable rh_user             { default = "" }
variable rh_password         { default = "" }
variable rh_serverurl        { default = "" }
variable rh_rhsm_baseurl     { default = "" }
variable image_id            { default = "" }
variable internal_ntp_server { default = "" }
  
module networking {
  source                = "./../../../../infrastructure/openstack/networking"

  project               = var.project
}

module common {
  source                = "./../../../../infrastructure/openstack/compute/common"

  project               = var.project
}

module snc_builder {
  source                = "./../../../../infrastructure/openstack/compute/services/snc-builder"
  depends_on            = [module.networking]

  project               = var.project
  private_network       = var.project
  keypair_name          = module.common.keypair_name
  rhel_version          = var.rhel_version
  flavor_name           = var.flavor_name
  rh_user               = var.rh_user
  rh_password           = var.rh_password
  rh_serverurl          = var.rh_serverurl
  rh_rhsm_baseurl       = var.rh_rhsm_baseurl
  image_id              = var.image_id
  internal_ntp_server   = var.internal_ntp_server
}

# This module create isolated VMs as so only one public ip will be joined
output public_ip { value = module.snc_builder.public_ip  }