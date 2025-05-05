resource "aws_eks_access_policy_association" "eks-access-policy" {
  for_each = toset(var.projectNames)

  cluster_name  = aws_eks_cluster.eks_cluster[each.key].name
  policy_arn    = var.policyArnEKSClusterAdminPolicy
  principal_arn = var.principalArn

  access_scope {
    type = "cluster"
  }
}