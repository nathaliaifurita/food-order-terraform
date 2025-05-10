output "eks_cluster_name" {
  for_each = toset(var.projectNames)
  value = aws_eks_cluster.eks_cluster[each.key].name
}

output "security_group_id" {
  value = aws_security_group.sg.id
}

output "eks_cluster_endpoint" {
  for_each = toset(var.projectNames)
  value = aws_eks_cluster.eks_cluster[each.key].endpoint
}

output "eks_cluster_certificate_authority_0_data" {
  for_each = toset(var.projectNames)
  value = aws_eks_cluster.eks_cluster[each.key].certificate_authority[0].data
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnets[*].id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnets[*].id
}