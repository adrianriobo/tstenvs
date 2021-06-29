variable project                  { default = "ms-corporate" }
variable external_network         { default = "provider_net_shared_3" }
variable private_subnet_cidr      { default = "172.16.0.0/24" }
variable static_ips_count         { default = 2 }
variable public_key_filepath      { default = "id_rsa.pub"}
variable win_local_admin_password { 
  default = "redhat20.21" 
  sensitive = true
}
variable domain                   { default = "crc.testing" }
variable domain_users             { 
  default = {"crc":"redhat20.21"}
  sensitive = true 
}
variable dc_safemode_password     { 
  default = "F/@p]*/*D/#2hC.6" 
  sensitive = true
}

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
  source                  = "./../../infrastructure/openstack/compute/services/domain-controller"

  project                 = var.project
  fixed_ip                = keys(module.networking.static_ips)[0]
  fixed_ip_port_id        = lookup(module.networking.static_ips, keys(module.networking.static_ips)[0], "")
  gateway_ip              = module.networking.gateway_ip
  external_network        = var.external_network
  keypair_name            = module.common.keypair_name
  dc_local_admin_password = var.win_local_admin_password
  dc_domain               = var.domain
  dc_users                = var.domain_users
  dc_safemode_password    = var.dc_safemode_password
}

module windows10 {
  source                = "./../../infrastructure/openstack/compute/guests/windows10"

  project               = var.project
  fixed_ip              = keys(module.networking.static_ips)[1]
  fixed_ip_port_id      = lookup(module.networking.static_ips, keys(module.networking.static_ips)[1], "")
  external_network      = var.external_network
  keypair_name          = module.common.keypair_name
  local_admin_password  = var.win_local_admin_password
  dc_readiness          = module.dc.dc_readiness
  dc_admin_user         = "Admin"
  dc_admin_password     = var.win_local_admin_password
  dc_fixed_ip           = module.dc.private_ip
  domain                = var.domain
  domain_users          = var.domain_users
}

output dc_public_ip         { value = module.dc.public_ip }
output dc_private_ip        { value = module.dc.private_ip }

output windows10_public_ip         { value = module.windows10.public_ip }
output windows10_private_ip        { value = module.windows10.private_ip }