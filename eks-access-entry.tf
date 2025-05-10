resource "aws_eks_access_entry" "eks_access_entry" {
  count = length(var.projectNames)

  cluster_name  = aws_eks_cluster.eks_cluster[*].name
  principal_arn = var.principalArn
  kubernetes_groups = ["food-order-api-groups"]
  type          = "STANDARD"
}