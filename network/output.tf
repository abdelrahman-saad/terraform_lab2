output vpc_id {
  value       = aws_vpc.myvpc.id
}
output "module_vpc_cider" {
  value       = aws_vpc.myvpc.cidr_block
}
output "private_subnets" {
  value       = aws_subnet.private_subnet
}
output "public_subnets" {
  value       = aws_subnet.public_subnet
}