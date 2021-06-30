# ms-corporate
IaC to create a corporate environment microsoft based

## Overview

![Overview](docs/diagrams/overview.jpg?raw=true)

## Container

Build
```bash
podman build -t terraform:1.0.0 .
```

Run
```bash
podman run -it --rm \
        --workdir=/provision \
        -v $PWD:/provision:Z \
        -e OS_AUTH_URL=XXX \
        -e OS_USERNAME=XXX \
        -e OS_TENANT_ID=XXX \
        -e OS_PROJECT_DOMAIN_ID=XXX \
        -e OS_PASSWORD=XXX \
        -e OS_USER_DOMAIN_NAME=XXX \
        localhost/terraform:1.0.0
```

### Cmds

Connect win domain machine

```bash
xfreerdp /v:$WIN_IP /u:$USER_NAME /d:$DOMAIN /p:$PASSWORD /sec:tls
```
