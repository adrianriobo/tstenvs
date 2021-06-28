variable project { default = "ms-corporate" }
variable external_network { default = "provider_net_shared_3" }
variable private_subnet_cidr { default = "172.16.0.0/24" }
variable static_ips_count { default = 2 }
variable public_key_filepath { default = "id_rsa.pub"}

module networking {
  source                = "./../../infrastructure/openstack/networking"

  project               = var.project
  external_network      = var.external_network
  private_subnet_cidr   = var.private_subnet_cidr
  static_ips_count      = var.static_ips_count
}

module common {
  source                = "./../../infrastructure/openstack/compute/common"

  project               = var.project
  public_key_filepath   = var.public_key_filepath
}

module dc {
  source                = "./../../infrastructure/openstack/compute/services/domain-controller"

  project               = var.project
  fixed_ip              = keys(module.networking.static_ips)[0]
  fixed_ip_port_id      = lookup(module.networking.static_ips, keys(module.networking.static_ips)[0], "")
  gateway_ip            = module.networking.gateway_ip
  external_network      = var.external_network
  keypair_name          = module.common.keypair_name
}

output network_id           { value = module.networking.network_id }
output gateway_ip           { value = module.networking.gateway_ip }
output static_ips           { value = module.networking.static_ips }
# output static_ips_port_ids  { value = module.networking.static_ips_port_ids }
output keypair_name         { value = module.common.keypair_name }

output dc_public_ip         { value = module.dc.public_ip }
output dc_private_ip        { value = module.dc.private_ip }