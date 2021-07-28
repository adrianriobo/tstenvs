variable project              {}
variable rh_user              {}
variable rh_password          {}
variable rhel_version         { description = "Sample version RHEL-8.5.0-20210629.n.1"}
variable flavor_name          { default = "ci.nested.virt.m4.xlarge.xmem" }
variable keypair_name         {}
variable security_groups { 
  type = list(string) 
  default = ["default"] 
}
# From persistent resources 
variable private_network      { default = "qe-platform" }
variable public_network       { default = "provider_net_shared_3" }

# Setup
locals {
   rhel9_user_data = <<USERDATA
#cloud-config  
rh_subscription:
  username: ${var.rh_user}
  password: ${var.rh_password}
  auto-attach: True
packages:
  - "@virt"
  - podman
  - chrony
package_upgrade: true
write_files:
  # cloud-init - NM dns management
  # https://access.redhat.com/solutions/4757761
  - content: |
      [main]
      dns = default
    path: /etc/NetworkManager/conf.d/9A-override-99-cloud-init.conf
  - content: |
      [baseos]
      name=baseos
      baseurl=http://download.eng.bos.redhat.com/rhel-9/nightly/RHEL-9-Beta/latest-RHEL-9.0.0/compose/BaseOS/x86_64/os
      gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
      sslcacert=/etc/rhsm/ca/redhat-uep.pem
      enabled=1
      gpgcheck=1
                                    
      [appstream]
      name=appstream
      baseurl=http://download.eng.bos.redhat.com/rhel-9/nightly/RHEL-9-Beta/latest-RHEL-9.0.0/compose/AppStream/x86_64/os
      gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
      sslcacert=/etc/rhsm/ca/redhat-uep.pem
      enabled=1
      gpgcheck=1
    path: /etc/yum.repos.d/linterop.repo
runcmd:
  - dnf group install -y "Development Tools"
  - [ systemctl, daemon-reload ]
  - [ systemctl, enable, libvirtd ]
  - [ systemctl, start, --no-block, libvirtd ] 
  - [ systemctl, start, --no-block, chronyd ] 
USERDATA
}

# Create ephemeral resources
resource openstack_compute_instance_v2 this {

  name              = "${var.project}-rhel9"
  image_name        = var.rhel_version
  flavor_name       = var.flavor_name
  key_pair          = var.keypair_name
  security_groups   = var.security_groups
  user_data         = local.rhel9_user_data

  network {
    name = var.private_network
  }
}

resource openstack_networking_floatingip_v2 this {
  pool = var.public_network
}

resource openstack_compute_floatingip_associate_v2 this {
  floating_ip = openstack_networking_floatingip_v2.this.address
  instance_id = openstack_compute_instance_v2.this.id
}

output public_ip  { value = openstack_networking_floatingip_v2.this.address }