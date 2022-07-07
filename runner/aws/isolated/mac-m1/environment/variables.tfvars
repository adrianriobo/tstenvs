aws-region          = "us-east-1"
project-name        = "crcqe"
key-name            = "tstenvs"                                
availability-zones  = ["us-east-1a", "us-east-1b", "us-east-1c"]
vpc-subnet-cidr     = "10.0.0.0/16"
intra-subnet-cidr   = ["10.0.0.0/19", "10.0.32.0/19", "10.0.64.0/19"]
public-subnet-cidr  = ["10.0.128.0/20", "10.0.144.0/20", "10.0.160.0/20"]
