aws_region          = "us-east-1"
project_name        = "crcqe"
key_name            = "tstenvs"                                
availability_zones  = ["us-east-1a", "us-east-1b", "us-east-1c"]
vpc_subnet_cidr     = "10.0.0.0/16"
intra_subnet_cidr   = ["10.0.0.0/19", "10.0.32.0/19", "10.0.64.0/19"]
public_subnet_cidr  = ["10.0.128.0/20", "10.0.144.0/20", "10.0.160.0/20"]
