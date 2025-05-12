resource "aws_eks_access_policy_association" "eks-access-policy" {
  cluster_name  = aws_eks_cluster.eks-cluster.name
  policy_arn    = var.policyArn
  principal_arn = var.principalArn

  access_scope {
    type = "cluster"
  }
}

resource "aws_iam_policy" "eks_passrole_labrole" {
  name        = "AllowPassRoleLabRole"
  description = "Allow passrole for EKS LabRole"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "iam:PassRole",
        Resource = "arn:aws:iam::198212171636:role/LabRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_passrole_to_voclabs" {
  role       = "voclabs"
  policy_arn = aws_iam_policy.eks_passrole_labrole.arn
}