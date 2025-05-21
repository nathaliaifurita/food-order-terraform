output "vpc_id" {
  value = local.vpc_id
}

output "private_subnet_ids" {
  value = local.private_subnet_ids
}

output "public_subnet_ids" {
  value = local.public_subnet_ids
}

output "security_group_id" {
  value       = local.security_group_id
  description = "ID do Security Group criado (se aplicável)"
}