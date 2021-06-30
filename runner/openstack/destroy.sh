#!/bin/bash

terraform init 

# Workaround for issue destroying
terraform state rm module.networking.openstack_networking_router_interface_v2.this
terraform state rm module.windows10.openstack_compute_interface_attach_v2.this

terraform destroy 

rm -rf id_rsa*
