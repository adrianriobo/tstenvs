#!/bin/bash

PROJECT="${1}"
RHEL_VERSION="${2}"
REPO_BASEOS_URL="${3}"
REPO_APPSTREAM_URL="${4}"
RH_USER="${5}"
RH_PASSWORD="${6}"

# Generate a key for the project
if [[ ! -f id_rsa ]]; then 
    ssh-keygen -t ecdsa -b 256 -f id_rsa -N ''
fi

terraform init

terraform plan -var project=${PROJECT} \
            -var rhel_version=${RHEL_VERSION} \
            -var repo_baseos_url=${REPO_BASEOS_URL} \
            -var repo_appstream_url=${REPO_APPSTREAM_URL} \
            -var rh_user=${RH_USER} \
            -var rh_password=${RH_PASSWORD} \
            -out=${PROJECT}.plan

terraform apply ${PROJECT}.plan

rm ${PROJECT}.plan
