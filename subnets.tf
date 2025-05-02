output "private_subnet_ids" {
  value = aws_subnet.private_subnets[each.key].id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnets[each.key].id
}
