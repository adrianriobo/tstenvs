# Networking
variable network-name { default = "ms-corporate" }
variable private-subnet-cidr { default = "192.168.199.0/24" }
variable default-gateway-ip { default = "192.168.199.1" }
variable router-name { default = "ms-corporate-router" }
#https://docs.engineering.redhat.com/pages/viewpage.action?pageId=63300728#PSIOpenStackOnboarding-OpenStackNetwork
variable public-network-name { default = "provider_net_shared_3" }
# Primary DC 
variable dc-image-name { default = "win-2019-serverstandard-x86_64-released_v2" }
variable dc-flavor-name { default = "m1.large" }
variable dc-fixed-ip { default = "192.168.199.209"}
# CRC guest host
variable guest-image-id { default = "98b9088b-2a08-4fa6-9ab3-2ed58fa9fbcb" } 
variable guest-flavor-name { default = "ci.nested.m1.large.xdisk.xmem" }

variable security-groups { 
  type = list(string) 
  default = ["default"] 
}