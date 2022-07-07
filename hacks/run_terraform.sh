#!/bin/bash

CONTAINER_RUNTIME="${CONTAINER_RUNTIME:-"podman"}"

${CONTAINER_RUNTIME} run -it \
    -v "$( dirname -- "$BASH_SOURCE"; )/../.":/project:Z \
    --entrypoint=sh \
    -e AWS_ACCESS_KEY_ID=${1} \
    -e AWS_SECRET_ACCESS_KEY=${2} \
    -e AWS_DEFAULT_REGION=us-east-1 \
    docker.io/hashicorp/terraform:latest
