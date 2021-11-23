#!/bin/sh

PROJECT="${1}"
FEDORA_VERSION="${2}"
IMAGE_ID="${3:-""}"

# Generate a key for the project
if [[ ! -f id_rsa ]]; then 
    ssh-keygen -t ecdsa -b 256 -f id_rsa -N ''
fi

terraform init

terraform plan -var project=${PROJECT} \
            -var fedora_version=${FEDORA_VERSION} \
            -var image_id=${IMAGE_ID} \
            -out=${PROJECT}.plan

terraform apply ${PROJECT}.plan

rm ${PROJECT}.plan
