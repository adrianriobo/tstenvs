variable project              {}
variable rh_user              {}
variable rh_password          {}


# Setup
locals {
   user_data = <<USERDATA
#cloud-config  
rh_subscription:
  username: ${var.rh_user}
  password: ${var.rh_password}
  #auto-attach: True
 
USERDATA
}