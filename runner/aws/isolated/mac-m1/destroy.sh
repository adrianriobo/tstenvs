#!/bin/sh

PROJECT="${1}"

# set -exuo pipefail

terraform init -backend-config=environment/remote-state.tf

terraform destroy -auto-approve -var-file=environment/variables.tfvars

rm .tstenvs