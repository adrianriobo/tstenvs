VERSION ?= 0.0.11
CONTAINER_MANAGER ?= podman
# Image URL to use all building/pushing image targets
IMG ?= quay.io/rhqp/tstenvs:v${VERSION}

# Build the container image
# Build the container image
.PHONY: oci-build
oci-build: 
	${CONTAINER_MANAGER} build -t ${IMG} -f oci/Containerfile.alpine .

# Push the container image
.PHONY: oci-push
oci-push:
	${CONTAINER_MANAGER} push ${IMG}