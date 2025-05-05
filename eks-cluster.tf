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

  # Adicionar a configuração de role para o EKS
  iam_role {
    role_arn = var.labRole
  }

  # Optionally, add logging
  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator"
  ]
}

# IAM Role para o EKS (assumindo que a role seja criada anteriormente)
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
  
  # Policies necessárias para o EKS
  inline_policy {
    name   = "eks-cluster-policy"
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
}
