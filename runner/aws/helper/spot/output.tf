locals {
    price_per_region = [
        {   "region": "us-east-1",
            "price" : module.us-east-1.best_price,
            "az"    : module.us-east-1.best_az
        },
        {   "region": "us-east-2",
            "price" : module.us-east-2.best_price,
            "az"    : module.us-east-2.best_az
        },
        {   "region": "us-west-1"
            "price" : module.us-west-1.best_price,
            "az"    : module.us-west-1.best_az
        },
        {   "region": "us-west-2"
            "price" : module.us-west-2.best_price,
            "az"    : module.us-west-2.best_az
        },
        # opt-int region
        # {   "region": "af-south-1"
        #     "price" : module.af-south-1.best_price,
        #     "az"    : module.af-south-1.best_az
        # },
        # opt-int region
        # {   "region": "ap-east-1"
        #     "price" : module.ap-east-1.best_price,
        #     "az"    : module.ap-east-1.best_az
        # },
        {   "region": "ap-south-1"
            "price" : module.ap-south-1.best_price,
            "az"    : module.ap-south-1.best_az
        },
        {   "region": "ap-northeast-1"
            "price" : module.ap-northeast-1.best_price,
            "az"    : module.ap-northeast-1.best_az
        },
        {   "region": "ap-northeast-2"
            "price" : module.ap-northeast-2.best_price,
            "az"    : module.ap-northeast-2.best_az
        },
        {   "region": "ap-northeast-3"
            "price" : module.ap-northeast-3.best_price,
            "az"    : module.ap-northeast-3.best_az
        },
        {   "region": "ap-southeast-1"
            "price" : module.ap-southeast-1.best_price,
            "az"    : module.ap-southeast-1.best_az
        },
        {   "region": "ap-southeast-2"
            "price" : module.ap-southeast-2.best_price,
            "az"    : module.ap-southeast-2.best_az
        },
        # opt-in region
        # {   "region": "ap-southeast-3"
        #     "price" : module.ap-southeast-3.best_price,
        #     "az"    : module.ap-southeast-3.best_az
        # }   
        {   "region": "ca-central-1"
            "price" : module.ca-central-1.best_price,
            "az"    : module.ca-central-1.best_az
        },
        {   "region": "eu-central-1"
            "price" : module.eu-central-1.best_price,
            "az"    : module.eu-central-1.best_az
        },   
        {   "region": "eu-west-1"
            "price" : module.eu-west-1.best_price,
            "az"    : module.eu-west-1.best_az
        },   
        {   "region": "eu-west-2"
            "price" : module.eu-west-2.best_price,
            "az"    : module.eu-west-2.best_az
        },   
        {   "region": "eu-west-3"
            "price" : module.eu-west-3.best_price,
            "az"    : module.eu-west-3.best_az
        },   
        # opt-in region
        # {   "region": "eu-south-1"
        #     "price" : module.eu-south-1.best_price,
        #     "az"    : module.eu-south-1.best_az
        # },   
        {   "region": "eu-north-1"
            "price" : module.eu-north-1.best_price,
            "az"    : module.eu-north-1.best_az
        },   
        # opt-in region
        # {   "region": "me-south-1"
        #     "price" : module.me-south-1.best_price,
        #     "az"    : module.me-south-1.best_az
        # },   
        {   "region": "sa-east-1"
            "price" : module.sa-east-1.best_price,
            "az"    : module.sa-east-1.best_az
        }   
    ]
}

locals {
    # Pick min price. Regions without price 
    price_min           = min([for item in local.price_per_region : 
        item.price]...)
    bid_exist           = local.price_min == local.non_offer_price ? false : true
    price_min_az        = local.bid_exist ? ([for item in local.price_per_region : 
        item.az if item.price == local.price_min][0]) : ""
    price_min_region    = local.bid_exist ? ([for item in local.price_per_region : 
        item.region if item.price == local.price_min][0]) : ""
}

output price_per_region { value = local.price_per_region }
output price_min        { value = local.bid_exist ? tostring(local.price_min) : "" }
output price_min_az     { value = local.price_min_az }
output price_min_region { value = local.price_min_region }