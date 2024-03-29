#!/bin/sh

PROJECT="${1}"
RH_USER="${2}"
RH_PASSWORD="${3}"
RH_SERVERURL="${RH_SERVERURL:-""}"
RH_RHSM_BASEURL="${RH_RHSM_BASEURL:-""}"
RHEL_VERSION="${RHEL_VERSION:-"RHEL-8.6.0-x86_64-released"}"
FLAVOUR_NAME="${FLAVOUR_NAME:-"ci.nested.virt.m5.large"}"
IMAGE_ID="${IMAGE_ID:-""}"
INTERNAL_NTP_SERVER="${INTERNAL_NTP_SERVER:-""}"

set -exuo pipefail

# Generate a key for the project
if [[ ! -f id_rsa ]]; then 
    ssh-keygen -t ecdsa -b 256 -f id_rsa -N ''
fi

terraform init

terraform plan -var project=${PROJECT} \
            -var rhel_version=${RHEL_VERSION} \
            -var flavor_name=${FLAVOUR_NAME} \
            -var rh_user=${RH_USER} \
            -var rh_password=${RH_PASSWORD} \
            -var rh_serverurl=${RH_SERVERURL} \
            -var rh_rhsm_baseurl=${RH_RHSM_BASEURL} \
            -var image_id=${IMAGE_ID} \
            -var internal_ntp_server=${INTERNAL_NTP_SERVER} \
            -out=${PROJECT}.plan

terraform apply ${PROJECT}.plan

rm ${PROJECT}.plan
