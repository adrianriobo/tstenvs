# tstenvs

IaC to multiple expected environments to test CRC  

* ms corporate (ms domain wiht joined member)
* pre released RHEL versions
* airgap scnearios
* security focused scenarios  

[![Repository on Quay](https://quay.io/repository/ariobolo/tstenvs/status "Repository on Quay")](https://quay.io/repository/ariobolo/tstenvs)

## Overview

![Overview](docs/diagrams/overview.jpg?raw=true)

## Container

Build

```bash  
podman build -t tstenvs:dev -f build/Dockerfile . 
```

Run

```bash
podman run -it --rm \
        -e OS_AUTH_URL=XXX \
        -e OS_USERNAME=XXX \
        -e OS_TENANT_ID=XXX \
        -e OS_PROJECT_DOMAIN_ID=XXX \
        -e OS_PASSWORD=XXX \
        -e OS_USER_DOMAIN_NAME=XXX \
        quay.io/ariobolo/tstenvs:$VERSION
```

### Cmds

Connect win domain machine

```bash
xfreerdp /v:$WIN_IP /u:$USER_NAME /d:$DOMAIN /p:$PASSWORD /sec:tls
```
