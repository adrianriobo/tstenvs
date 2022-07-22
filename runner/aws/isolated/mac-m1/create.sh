#!/bin/sh

# set -exuo pipefail

RUNNER_ID="isolated-mac-m1"

terraform init -backend-config=environment/remote-state.tf

terraform plan -var-file=environment/variables.tfvars \
    -out=${RUNNER_ID}.plan

terraform apply ${RUNNER_ID}.plan

rm ${RUNNER_ID}.plan
