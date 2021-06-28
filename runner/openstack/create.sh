#!/bin/bash

PROJECT="ms-corporate"

# Generate a key for the project
if [[ ! -f id_rsa ]]; then 
    ssh-keygen -t ecdsa -b 256 -f id_rsa -N ''
fi

terraform init

terraform plan -var project=${PROJECT} -out=${PROJECT}.plan

terraform apply ${PROJECT}.plan

rm ${PROJECT}.plan
