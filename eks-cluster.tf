resource "aws_eks_cluster" "eks_cluster" {
  for_each = toset(var.projectNames)

  name     = "eks-${each.key}"
  role_arn = var.labRole  # Certifique-se de que essa role tenha as permissões necessárias para o EKS

  vpc_config {
    subnet_ids            = [for subnet in values(aws_subnet.private_subnets) : subnet.id]
    security_group_ids    = [aws_security_group.sg[each.key].id]
    endpoint_public_access = true  # Defina como true se você precisar acessar o endpoint do EKS publicamente
    endpoint_private_access = false # Altere conforme necessário para acessar privadamente
  }

  # Configuração de autenticação
  access_config {
    authentication_mode = var.accessConfig  # Verifique se 'var.accessConfig' está bem configurado
  }

  # Tags para identificar o cluster
  tags = {
    Project = each.key
  }

  # Optionally, add logging
  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator"
  ]
}

# IAM Role para o EKS (sem inline_policy, agora usando aws_iam_role_policy)
resource "aws_iam_role" "eks_role" {
  name               = "eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow"
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

# Policy para a Role do EKS
resource "aws_iam_role_policy" "eks_role_policy" {
  name   = "eks-cluster-policy"
  role   = aws_iam_role.eks_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "eks:CreateCluster",
          "eks:DescribeCluster",
          "eks:UpdateClusterConfig",
          "eks:UpdateClusterVersion",
          "eks:DeleteCluster"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = "ec2:DescribeInstances"
        Resource = "*"
      }
    ]
  })
}
