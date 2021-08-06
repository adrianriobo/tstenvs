#!/bin/bash

PROJECT="${1}"
RHEL_VERSION="${2}"

terraform init 

#mocked id_rsa.pub for file function
touch id_rsa.pub

terraform destroy -auto-approve \
                -var project=${PROJECT} \
                -var rhel_version=${RHEL_VERSION}
