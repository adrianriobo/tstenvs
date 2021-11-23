variable project             {}
variable fedora_version      { default = "" }
variable image_id            { default = "" }
  
module networking {
  source                = "./../../../../infrastructure/openstack/networking"

  project               = var.project
}

module common {
  source                = "./../../../../infrastructure/openstack/compute/common"

  project               = var.project
}

module fedora {
  source                = "./../../../../infrastructure/openstack/compute/guests/fedora"
  depends_on            = [module.networking]

  project               = var.project
  private_network       = var.project
  keypair_name          = module.common.keypair_name
  fedora_version        = var.fedora_version
  image_id              = var.image_id
}

# This module create isolated VMs as so only one public ip will be joined
output public_ip { value = module.fedora.public_ip  }