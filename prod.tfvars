region                        = "eu-central-1"
vpc_cidr                      = "10.0.0.0/16"
public_subnets_cidr           = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets_cidr          = ["10.0.3.0/24", "10.0.4.0/24"]
availability_zones            = ["eu-central-1a", "eu-central-1b"]
image_id                      = "ami-04e601abe3e1a910f"
# anywhere_cider                = "[0.0.0.0/0]"
instance_type                 = "t2.micro"
