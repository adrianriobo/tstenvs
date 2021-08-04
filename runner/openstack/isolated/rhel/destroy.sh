#!/bin/bash

PROJECT="${1}"

terraform init 

#mocked id_rsa.pub for file function
touch id_rsa.pub

terraform destroy -auto-approve \
                -var project=${PROJECT}
