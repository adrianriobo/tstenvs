#!/bin/bash

PROJECT="${1}"
RHEL_MAJOR="${2}"
RHEL_VERSION="${3}"

terraform init 

terraform destroy -auto-approve \
                -var project=${PROJECT} \
                -var rhel_major=${RHEL_MAJOR} \
                -var rhel_version=${RHEL_VERSION}
