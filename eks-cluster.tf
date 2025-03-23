resource "aws_eks_cluster" "eks-cluster" {
  name     = var.projectName 
  role_arn = var.labRole
  
  vpc_config {
    subnet_ids         = aws_subnet.private_subnets[*].id
    security_group_ids = [aws_security_group.sg.id]
  }

  access_config {
    authentication_mode = var.accessConfig
  }

  depends_on = [
    aws_iam_role.eks_role
  ]
}
