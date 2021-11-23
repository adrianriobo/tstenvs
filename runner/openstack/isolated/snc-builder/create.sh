#!/bin/sh

PROJECT="${1}"
RH_USER="${2}"
RH_PASSWORD="${3}"
RHEL_VERSION="${4:-"RHEL-8.4.0-x86_64-production-latest"}"
IMAGE_ID="${5:-""}"

# Generate a key for the project
if [[ ! -f id_rsa ]]; then 
    ssh-keygen -t ecdsa -b 256 -f id_rsa -N ''
fi

terraform init

terraform plan -var project=${PROJECT} \
            -var rhel_version=${RHEL_VERSION} \
            -var rh_user=${RH_USER} \
            -var rh_password=${RH_PASSWORD} \
            -var image_id=${IMAGE_ID} \
            -out=${PROJECT}.plan

terraform apply ${PROJECT}.plan

rm ${PROJECT}.plan
