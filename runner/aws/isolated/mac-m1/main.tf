variable key-name {}
variable aws-region{}
  
module key {
  source     = "./../../../../infrastructure/aws/common/keys"

  key-name   = var.key-name
  aws-region = var.aws-region
}

# This module create isolated VMs as so only one public ip will be joined
output key-name { value = module.key.key-name }
output key-private { 
  value = module.key.key-private
  sensitive = true  
}
output key-public { 
  value = module.key.key-public  
  sensitive = true
}