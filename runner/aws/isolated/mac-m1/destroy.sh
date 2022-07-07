#!/bin/sh

PROJECT="${1}"

# set -exuo pipefail

terraform init 

terraform destroy -auto-approve \
    -var key-name=${PROJECT} \
    -var aws-region=${AWS_DEFAULT_REGION}
