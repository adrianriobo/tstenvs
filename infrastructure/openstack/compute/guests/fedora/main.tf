# Id
variable project              {}
# Fedora params
variable fedora_version       {}
# VM params
variable flavor_name          {}
variable image_id             { default = "" }
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
variable username             { default = "fedora" }
variable private_key_filepath { default = "id_rsa" }
variable setup_timeout        { default = "12m" }

# Setup
locals {
  name = "${var.project}-${var.fedora_version}"

  fedora_user_data = <<USERDATA
#cloud-config  
packages:
  - podman
package_upgrade: true
USERDATA
}

data openstack_images_image_ids_v2 this {
  name_regex = "${var.fedora_version}*"
  sort       = "updated_at"
}

# Create ephemeral resources

# Create a volume with extended disk capacity
resource openstack_blockstorage_volume_v3 this {
  name        = local.name
  image_id    = var.image_id != "" ? var.image_id : data.openstack_images_image_ids_v2.this.ids[0]
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
  user_data         = local.fedora_user_data

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

resource null_resource cloud_init_wait {
  depends_on = [openstack_compute_floatingip_associate_v2.this]

  connection {
    user = var.username
    private_key = file(var.private_key_filepath)
    host = openstack_networking_floatingip_v2.this.address
    timeout = var.setup_timeout
  }

  # Wait for cloud-init finish
  provisioner "remote-exec" {
    inline = ["sudo cloud-init status --wait"]
  }
}

output public_ip  { value = openstack_networking_floatingip_v2.this.address }