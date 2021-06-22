# ms-corporate
IaC to create a corporate environment microsoft based

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
        --dns 10.38.5.26 \
        localhost/terraform:1.0.0
```
