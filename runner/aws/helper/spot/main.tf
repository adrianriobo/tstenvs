# https://github.com/hashicorp/terraform/issues/19932
# For the moment it is not possible to dynamic provisioning providers
# workaround is create a module per region then from results check and offer best option

# Include non opt-in regions
# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html

module us-east-1 {
    source              = "./../../../../infrastructure/aws/common/spot"
    providers           = {
        aws             = aws.us-east-1
    }
    instance_type       = var.instance_type
    product_description = var.product_description
    non_offer_price     = local.non_offer_price
}

module us-east-2 {
    source              = "./../../../../infrastructure/aws/common/spot"
    providers           = {
        aws             = aws.us-east-2
    }
    instance_type       = var.instance_type
    product_description = var.product_description
    non_offer_price     = local.non_offer_price
}

module us-west-1 {
    source              = "./../../../../infrastructure/aws/common/spot"
    providers           = {
        aws             = aws.us-west-1
    }
    instance_type       = var.instance_type
    product_description = var.product_description
    non_offer_price     = local.non_offer_price
}

module us-west-2 {
    source              = "./../../../../infrastructure/aws/common/spot"
    providers           = {
        aws             = aws.us-west-2
    }
    instance_type       = var.instance_type
    product_description = var.product_description
    non_offer_price     = local.non_offer_price
}

# opt-in region
# module af-south-1 {
#     source              = "./../../../../infrastructure/aws/common/spot"
#     providers           = {
#         aws             = aws.af-south-1
#     }
#     instance_type       = var.instance_type
#     product_description = var.product_description
#     non_offer_price     = local.non_offer_price
# }

# opt-in region
# module ap-east-1 {
#     source              = "./../../../../infrastructure/aws/common/spot"
#     providers           = {
#         aws             = aws.ap-east-1
#     }
#     instance_type       = var.instance_type
#     product_description = var.product_description
#     non_offer_price     = local.non_offer_price
# }

module ap-south-1 {
    source              = "./../../../../infrastructure/aws/common/spot"
    providers           = {
        aws             = aws.ap-south-1
    }
    instance_type       = var.instance_type
    product_description = var.product_description
    non_offer_price     = local.non_offer_price
}

module ap-northeast-1 {
    source              = "./../../../../infrastructure/aws/common/spot"
    providers           = {
        aws             = aws.ap-northeast-1
    }
    instance_type       = var.instance_type
    product_description = var.product_description
    non_offer_price     = local.non_offer_price
}

module ap-northeast-2 {
    source              = "./../../../../infrastructure/aws/common/spot"
    providers           = {
        aws             = aws.ap-northeast-2
    }
    instance_type       = var.instance_type
    product_description = var.product_description
    non_offer_price     = local.non_offer_price
}

module ap-northeast-3 {
    source              = "./../../../../infrastructure/aws/common/spot"
    providers           = {
        aws             = aws.ap-northeast-3
    }
    instance_type       = var.instance_type
    product_description = var.product_description
    non_offer_price     = local.non_offer_price
}

module ap-southeast-1 {
    source              = "./../../../../infrastructure/aws/common/spot"
    providers           = {
        aws             = aws.ap-southeast-1
    }
    instance_type       = var.instance_type
    product_description = var.product_description
    non_offer_price     = local.non_offer_price
}

module ap-southeast-2 {
    source              = "./../../../../infrastructure/aws/common/spot"
    providers           = {
        aws             = aws.ap-southeast-2
    }
    instance_type       = var.instance_type
    product_description = var.product_description
    non_offer_price     = local.non_offer_price
}

# opt-in region
# module ap-southeast-3 {
#     source              = "./../../../../infrastructure/aws/common/spot"
#     providers           = {
#         aws             = aws.ap-southeast-3
#     }
#     instance_type       = var.instance_type
#     product_description = var.product_description
#     non_offer_price     = local.non_offer_price
# }

module ca-central-1 {
    source              = "./../../../../infrastructure/aws/common/spot"
    providers           = {
        aws             = aws.ca-central-1
    }
    instance_type       = var.instance_type
    product_description = var.product_description
    non_offer_price     = local.non_offer_price
}

module eu-central-1 {
    source              = "./../../../../infrastructure/aws/common/spot"
    providers           = {
        aws             = aws.eu-central-1
    }
    instance_type       = var.instance_type
    product_description = var.product_description
    non_offer_price     = local.non_offer_price
}

module eu-west-1 {
    source              = "./../../../../infrastructure/aws/common/spot"
    providers           = {
        aws             = aws.eu-west-1
    }
    instance_type       = var.instance_type
    product_description = var.product_description
    non_offer_price     = local.non_offer_price
}

module eu-west-2 {
    source              = "./../../../../infrastructure/aws/common/spot"
    providers           = {
        aws             = aws.eu-west-2
    }
    instance_type       = var.instance_type
    product_description = var.product_description
    non_offer_price     = local.non_offer_price
}

module eu-west-3 {
    source              = "./../../../../infrastructure/aws/common/spot"
    providers           = {
        aws             = aws.eu-west-3
    }
    instance_type       = var.instance_type
    product_description = var.product_description
    non_offer_price     = local.non_offer_price
}

# opt-in region
# module eu-south-1 {
#     source              = "./../../../../infrastructure/aws/common/spot"
#     providers           = {
#         aws             = aws.eu-south-1
#     }
#     instance_type       = var.instance_type
#     product_description = var.product_description
#     non_offer_price     = local.non_offer_price
# }

module eu-north-1 {
    source              = "./../../../../infrastructure/aws/common/spot"
    providers           = {
        aws             = aws.eu-north-1
    }
    instance_type       = var.instance_type
    product_description = var.product_description
    non_offer_price     = local.non_offer_price
}

# opt-in region
# module me-south-1 {
#     source              = "./../../../../infrastructure/aws/common/spot"
#     providers           = {
#         aws             = aws.me-south-1
#     }
#     instance_type       = var.instance_type
#     product_description = var.product_description
#     non_offer_price     = local.non_offer_price
# }

module sa-east-1 {
    source              = "./../../../../infrastructure/aws/common/spot"
    providers           = {
        aws             = aws.sa-east-1
    }
    instance_type       = var.instance_type
    product_description = var.product_description
    non_offer_price     = local.non_offer_price
}
