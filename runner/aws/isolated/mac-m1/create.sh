#!/bin/sh

PROJECT="${1}"

# set -exuo pipefail

terraform init

terraform plan -var key-name=${PROJECT} \
    -var aws-region=${AWS_DEFAULT_REGION} \
    -out=${PROJECT}.plan

terraform apply ${PROJECT}.plan

rm ${PROJECT}.plan
