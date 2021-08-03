# Id
variable project              {}
# RHEL params
variable rhel_version         { default = "no-need-used-for-destroy"}
variable repo_baseos_url      { default = "no-need-used-for-destroy"}
variable repo_appstream_url   { default = "no-need-used-for-destroy"}
variable rh_user              { default = "no-need-used-for-destroy" }
variable rh_password          { default = "no-need-used-for-destroy" }
# VM params
variable flavor_name          { default = "ci.nested.virt.m4.xlarge.xmem" }
variable disk_size            { default = 90 }
variable disk_type            { default = "ceph" }
variable keypair_name         {}
# Netowrking params
variable security_groups { 
  type = list(string) 
  default = ["default"] 
}
variable private_network      {}
variable public_network       { default = "provider_net_shared_3" }

# Setup
locals {
  rhel_user_data = <<USERDATA
#cloud-config  
rh_subscription:
  username: ${var.rh_user}
  password: ${var.rh_password}
  auto-attach: True
packages:
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
      baseurl=${var.repo_baseos_url}
      gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
      sslcacert=/etc/rhsm/ca/redhat-uep.pem
      enabled=1
      gpgcheck=1
                                    
      [appstream]
      name=appstream
      baseurl=${var.repo_appstream_url}
      gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
      sslcacert=/etc/rhsm/ca/redhat-uep.pem
      enabled=1
      gpgcheck=1
    path: /etc/yum.repos.d/linterop.repo
runcmd:
  - [ systemctl, daemon-reload ]
  - [ systemctl, enable, libvirtd ]
  - [ systemctl, start, --no-block, libvirtd ] 
  - [ systemctl, start, --no-block, chronyd ] 
USERDATA
  # Change the name to pattern with version
  image_name = var.rhel_version
  name = "${var.project}-rhel9"
}

data openstack_images_image_v2 this {
  name        = local.image_name
  most_recent = true
}

# Create ephemeral resources

# Create a volume with extended disk capacity
resource openstack_blockstorage_volume_v3 this {
  name        = local.name
  image_id    = data.openstack_images_image_v2.this.id
  size        = var.disk_size
  volume_type = var.disk_type

  timeouts {
    create = "15m"
  }
}


resource openstack_compute_instance_v2 this {
  name              = local.name
  flavor_name       = var.flavor_name
  key_pair          = var.keypair_name
  security_groups   = var.security_groups
  user_data         = local.rhel_user_data

  block_device {
    uuid                  = openstack_blockstorage_volume_v3.this.id
    source_type           = "volume"
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

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