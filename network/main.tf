# ###############################
# ######     VPC    #############

# resource "aws_vpc" "my_vpc" {
#   cidr_block = var.vpc_cidr_block
#   instance_tenancy = "default"

#   tags = {
#     Name = "my-vpc"
#   }
# }

# ###############################
# ######     subnets    #########

# resource "aws_subnet" "public_subnet" {
#   count                   = length(var.availability_zones)
#   vpc_id                  = aws_vpc.myvpc.id
#   cidr_block              = var.public_subnets_cidr[count.index]
#   availability_zone       = var.availability_zones[count.index]
#   map_public_ip_on_launch = true
#   tags = {
#     Name = "Public-Subnet-${count.index}"
#   }
# }

# resource "aws_subnet" "private_subnet" {
#   count                   = length(var.availability_zones)
#   vpc_id                  = aws_vpc.myvpc.id
#   cidr_block              = var.private_subnets_cidr[count.index]
#   availability_zone       = var.availability_zones[count.index]
#   map_public_ip_on_launch = true
#   tags = {
#     Name = "Private-Subnet-${count.index}"
#   }
# }


# ###############################
# ###### public route table #####

# resource "aws_route_table" "public_table" {
#   vpc_id = aws_vpc.myvpc.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.gw.id
#   }
# }

# resource "aws_route_table_association" "public_subnet_association" {
#   count          = length(var.availability_zones)
#   subnet_id      = aws_subnet.public_subnet[count.index].id
#   route_table_id = aws_route_table.public_table.id
# }

# ###############################
# ###### private route table ####
# resource "aws_route_table" "private_table" {
#   vpc_id = aws_vpc.myvpc.id
# }

# resource "aws_route_table_association" "private_subnet_association" {
#   count          = length(var.availability_zones)
#   subnet_id      = aws_subnet.private_subnet[count.index].id
#   route_table_id = aws_route_table.private_table.id
# }


# ###############################
# ###### Internet Gateway #######

# resource "aws_internet_gateway" "gw" {
#   vpc_id = aws_vpc.myvpc.id

#   tags = {
#     Name = "igw-myvpc"
#   }
# }
