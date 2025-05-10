resource "aws_eks_access_policy_association" "eks-access-policy" {
  count = length(var.projectNames)

  cluster_name  = aws_eks_cluster.eks_cluster[count.index].name
  policy_arn    = var.policyArnEKSClusterAdminPolicy
  principal_arn = var.principalArn

  access_scope {
    type = "cluster"
  }
}