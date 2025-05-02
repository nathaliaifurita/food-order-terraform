resource "aws_eks_cluster" "eks_cluster" {
  for_each = toset(var.project_names)

  name     = "eks-${each.key}"  # Aqui sim é uma string
  role_arn = var.labRole

  vpc_config {
    subnet_ids         = aws_subnet.private_subnets[*].id
    security_group_ids = [aws_security_group.sg.id]
  }

  access_config {
    authentication_mode = var.accessConfig
  }

  tags = {
    Project = each.key
  }
}