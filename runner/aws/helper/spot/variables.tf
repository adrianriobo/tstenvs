variable aws_region             { default = "us-east-1" }
variable instance_type          { default = "m5dn.metal" }
variable product_description    { default = "Windows" }
variable regions                { 
    type    = list(string)
    default = ["all"] 
    validation {
        # Add foreach element on regions should exist on all_regions
        condition     = length(var.regions) > 0 
        error_message = "At least one region or all should be set as regions"
    }
}

locals {
    # List all regions in case "all" is set for search
    # may not used anymore as need to explictly have all of them
    # keep in case dynamic provision is added to tf
    # or may as workaround use jinja and templating a module based on regions
    # Include non opt-in regions
    # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html
    all_regions = tolist([
        "us-east-1",
        "us-east-2",
        "us-west-1",
        "us-west-2",
        # "af-south-1", #opt-in
        # "ap-east-1", #opt-in
        "ap-south-1",
        "ap-northeast-1",
        "ap-northeast-2",
        "ap-northeast-3",
        "ap-southeast-1",
        "ap-southeast-2",
        # "ap-southeast-3", #opt-in
        "ca-central-1",
        "eu-central-1",
        "eu-west-1",
        "eu-west-2",
        "eu-west-3",
        # "eu-south-1", #opt-in
        "eu-north-1",
        # "me-south-1", #opt-in
        "sa-east-1"
    ])
    # check if only specific regions or all
    assessable_regions = (length(var.regions) == 1 
        && element(var.regions, 0) == "all") ? local.all_regions : var.regions
    # fixed value to discard regions without offerings
    non_offer_price = "5000"
}
