region                        = "us-east-1"
vpc_cidr                      = "10.0.0.0/16"
public_subnets_cidr           = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets_cidr          = ["10.0.3.0/24", "10.0.4.0/24"]
availability_zones            = ["us-east-1a", "us-east-1b"]
image_id                      = "ami-03a6eaae9938c858c"
# anywhere_cider                = "[0.0.0.0/0]"
instance_type                 = "t2.micro"
