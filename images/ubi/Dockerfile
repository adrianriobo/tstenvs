FROM registry.access.redhat.com/ubi8/ubi-minimal AS downloader

# TODO move to ARG
ENV TERRAFORM_VERSION 1.0.0
ENV TERRAFORM_URL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip 

RUN microdnf install -y zip \
    && curl -Lo /tmp/terraform.zip $TERRAFORM_URL \
    && unzip /tmp/terraform.zip -d /tmp/
    

FROM registry.access.redhat.com/ubi8/ubi-minimal

LABEL org.opencontainers.image.authors="ariobolo@redhat.com"

COPY --from=downloader /tmp/terraform /usr/local/bin/terraform

COPY . /opt/iac

ENV EPEL https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

RUN rpm -ivh ${EPEL} \ 
    && microdnf --enablerepo=epel install -y openssh-clients sshpass ncurses \
    && microdnf clean all

WORKDIR /opt/iac/runner
