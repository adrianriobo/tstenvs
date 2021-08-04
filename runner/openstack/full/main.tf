variable project                  { default = "ms-corporate" }
variable external_network         { default = "provider_net_shared_3" }
variable private_subnet_cidr      { default = "172.16.0.0/24" }
variable static_ips_count         { default = 0 }
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
variable rh_user              { 
  default = "no-need" 
  description = "username for rh suscription" 
}
variable rh_password          { 
  default = "no-need" 
  description = "password for rh suscription" 
}
  

module networking {
  source                = "./../../../infrastructure/openstack/networking"

  project               = var.project
  external_network      = var.external_network
  private_subnet_cidr   = var.private_subnet_cidr
  static_ips_count      = var.static_ips_count
}

module common {
  source                = "./../../../infrastructure/openstack/compute/common"

  project               = var.project
  public_key_filepath   = var.public_key_filepath
}

module dc {
  source                  = "./../../../infrastructure/openstack/compute/services/domain-controller"

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
  source                = "./../../../infrastructure/openstack/compute/guests/windows10"

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

module rhel85 {
  source                = "./../../../infrastructure/openstack/compute/guests/rhel"

  depends_on = [module.networking]

  project               = var.project
  public_network        = var.external_network
  private_network       = var.project
  keypair_name          = module.common.keypair_name
  rh_user               = var.rh_user
  rh_password           = var.rh_password
  rhel_version          = "RHEL-8.5.0-x86_64-nightly-latest"
  repo_baseos_url       = "http://download.eng.bos.redhat.com/rhel-8/nightly/RHEL-8/latest-RHEL-8.5.0/compose/BaseOS/x86_64/os"
  repo_appstream_url    = "http://download.eng.bos.redhat.com/rhel-8/nightly/RHEL-8/latest-RHEL-8.5.0/compose/AppStream/x86_64/os" 
}

module rhel9 {
  source                = "./../../../infrastructure/openstack/compute/guests/rhel"

  depends_on = [module.networking]

  project               = var.project
  public_network        = var.external_network
  private_network       = var.project
  keypair_name          = module.common.keypair_name
  rh_user               = var.rh_user
  rh_password           = var.rh_password
  rhel_version          = "RHEL-9.0.0-x86_64-nightly-latest"
  repo_baseos_url       = "http://download.eng.bos.redhat.com/rhel-9/nightly/RHEL-9-Beta/latest-RHEL-9.0.0/compose/BaseOS/x86_64/os"
  repo_appstream_url    = "http://download.eng.bos.redhat.com/rhel-9/nightly/RHEL-9-Beta/latest-RHEL-9.0.0/compose/AppStream/x86_64/os" 
}

output dc_public_ip           { value = module.dc.public_ip }
output dc_private_ip          { value = module.dc.private_ip }

output windows10_public_ip    { value = module.windows10.public_ip }
output windows10_private_ip   { value = module.windows10.private_ip }

output rhel85_public_ip       { value = module.rhel85.public_ip }
output rhel9_public_ip        { value = module.rhel9.public_ip }