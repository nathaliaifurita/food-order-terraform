output "eks_cluster_name" {
  value = aws_eks_cluster.eks_cluster[each.key].name
}

output "security_group_id" {
  value = aws_security_group.sg.id
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.eks_cluster[each.key].endpoint
}

output "eks_cluster_certificate_authority_0_data" {
  value = aws_eks_cluster.eks_cluster.[each.key].certificate_authority[0].data
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnets[*].id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnets[*].id
}