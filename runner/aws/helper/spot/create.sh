#!/bin/bash

# set -exuo pipefail

terraform init

terraform apply -var regions="[\"us-east-1\"]" -auto-approve 
