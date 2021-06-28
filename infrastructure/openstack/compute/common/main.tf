variable project {}
variable public_key_filepath {}


resource openstack_compute_keypair_v2 this {
  name       = var.project
  public_key = file(var.public_key_filepath)
}

output keypair_name { value = openstack_compute_keypair_v2.this.name }
