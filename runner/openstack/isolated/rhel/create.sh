#!/bin/sh

PROJECT="${1}"
RHEL_VERSION="${2}"
RH_USER="${3}"
RH_PASSWORD="${4}"
REPO_BASEOS_URL="${5:-""}"
REPO_APPSTREAM_URL="${6:-""}"
IMAGE_ID="${7:-""}"
FLAVOUR_NAME="${FLAVOUR_NAME:-"ci.nested.virt.m4.xlarge.xmem"}"

# Generate a key for the project
if [[ ! -f id_rsa ]]; then 
    ssh-keygen -t ecdsa -b 256 -f id_rsa -N ''
fi

terraform init

terraform plan -var project=${PROJECT} \
            -var rhel_version=${RHEL_VERSION} \
            -var flavor_name=${FLAVOUR_NAME} \
            -var repo_baseos_url=${REPO_BASEOS_URL} \
            -var repo_appstream_url=${REPO_APPSTREAM_URL} \
            -var rh_user=${RH_USER} \
            -var rh_password=${RH_PASSWORD} \
            -var image_id=${IMAGE_ID} \
            -out=${PROJECT}.plan

terraform apply ${PROJECT}.plan

rm ${PROJECT}.plan
