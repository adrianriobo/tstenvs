#!/bin/sh

PROJECT="${1}"
RHEL_VERSION="${2:-"RHEL-8.6.0-x86_64-released"}"
IMAGE_ID="${3:-""}"

set -exuo pipefail

terraform init 

#mocked id_rsa.pub for file function
touch id_rsa.pub

terraform destroy -auto-approve \
                -var project=${PROJECT} \
                -var rhel_version=${RHEL_VERSION} \
                -var image_id=${IMAGE_ID}
