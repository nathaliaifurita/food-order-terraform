output "eks_cluster_name" {
  count = length(var.projectNames)
  value = aws_eks_cluster.eks_cluster[count.index].name
}

output "security_group_id" {
  value = aws_security_group.sg.id
}

output "eks_cluster_endpoint" {
  count = length(var.projectNames)
  value = aws_eks_cluster.eks_cluster[count.index].endpoint
}

output "eks_cluster_certificate_authority_0_data" {
  count = length(var.projectNames)
  value = aws_eks_cluster.eks_cluster[count.index].certificate_authority[0].data
}

output "private_subnet_ids" {
  count = length(var.projectNames)
  value = aws_subnet.private_subnets[count.index].id
}

output "public_subnet_ids" {
  count = length(var.projectNames)
  value = aws_subnet.public_subnets[count.index].id
}