#!/bin/sh

PROJECT="${1}"
FEDORA_VERSION="${2}"
IMAGE_ID="${3:-""}"

set -exuo pipefail

terraform init 

#mocked id_rsa.pub for file function
touch id_rsa.pub

terraform destroy -auto-approve \
                -var project=${PROJECT} \
                -var fedora_version=${FEDORA_VERSION} \
                -var image_id=${IMAGE_ID}
