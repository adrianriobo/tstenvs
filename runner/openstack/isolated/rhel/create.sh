#!/bin/bash

PROJECT="${1}"
RH_USER="${2}"
RH_PASSWORD="${3}"
RHEL_MAJOR="${4}"
RHEL_VERSION="${5}"


# Generate a key for the project
if [[ ! -f id_rsa ]]; then 
    ssh-keygen -t ecdsa -b 256 -f id_rsa -N ''
fi

terraform init

terraform plan -var project=${PROJECT} \
            -var rh_user=${RH_USER} \
            -var rh_password=${RH_PASSWORD} \
            -var rhel_major=${RHEL_MAJOR} \
            -var rhel_version=${RHEL_VERSION} \
            -out=${PROJECT}.plan

terraform apply ${PROJECT}.plan

rm ${PROJECT}.plan
