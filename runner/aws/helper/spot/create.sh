#!/bin/bash

# set -exuo pipefail

ALL_REGIONS=(
    "us-east-1" 
    "us-east-2" 
    "us-west-1"
)

if [ "$#" -eq 0 ]; then
  REGIONS=${ALL_REGIONS[@]}
else
  REGIONS=( "$@" )
fi

terraform init

for region in ${REGIONS[@]}; do
    echo ${region}
    terraform apply -var aws_region=${region} -state=${region}.tfstate -auto-approve 
done