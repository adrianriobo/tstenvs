#!/bin/bash

CONTAINER_RUNTIME="${CONTAINER_RUNTIME:-"podman"}"

${CONTAINER_RUNTIME} run -it \
    -v "$( dirname -- "$BASH_SOURCE"; )/../../.":/project:Z \
    --entrypoint=sh \
    -e OS_AUTH_URL=https://rhos-d.infra.prod.upshift.rdu2.redhat.com:13000/v3 \
    -e OS_USERNAME=${1} \
    -e OS_TENANT_ID=${2} \
    -e OS_PROJECT_DOMAIN_ID=${3} \
    -e OS_PASSWORD=${4} \
    -e OS_USER_DOMAIN_NAME=redhat.com \
    --dns 10.38.5.26 \
    docker.io/hashicorp/terraform:latest
