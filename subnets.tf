output "private_subnet_ids" {
  value = { for k, s in aws_subnet.private_subnets : k => s.id }
}

output "public_subnet_ids" {
  value = { for k, s in aws_subnet.public_subnets : k => s.id }
}