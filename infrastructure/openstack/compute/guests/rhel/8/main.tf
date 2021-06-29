variable project              {}
variable rh_user              {}
variable rh_password          {}
variable rhel_version         { description = "Sample version RHEL-8.5.0-20210629.n.1"}


# Setup
locals {
   user_data = <<USERDATA
#cloud-config  
rh_subscription:
  username: ${var.rh_user}
  password: ${var.rh_password}
  auto-attach: True
packages:
  - "@virt"
  - "Development Tools"
write_files:
  # cloud-init - NM dns management
  # https://access.redhat.com/solutions/4757761
  - content: |
      [main]
      dns = default
    path: /etc/NetworkManager/conf.d/9A-override-99-cloud-init.conf
  - content: |
      [baseos]
      name=baseos
      baseurl=http://download.eng.bos.redhat.com/rhel-8/nightly/RHEL-8/${var.rhel_version}/compose/BaseOS/x86_64/os
      gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
      sslcacert=/etc/rhsm/ca/redhat-uep.pem
      enabled=1
      gpgcheck=1
                                    
      [appstream]
      name=appstream
      baseurl=http://download.eng.bos.redhat.com/rhel-8/nightly/RHEL-8/${var.rhel_version}/compose/AppStream/x86_64/os
      gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
      sslcacert=/etc/rhsm/ca/redhat-uep.pem
      enabled=1
      gpgcheck=1
    path: /etc/yum.repos.d/linterop.repo

 
USERDATA
}