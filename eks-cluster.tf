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

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.eks-cluster.name
  addon_name   = "kube-proxy"
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.eks-cluster.name
  addon_name   = "vpc-cni"
}

resource "aws_eks_addon" "eks-node-monitoring-agent" {
  cluster_name = aws_eks_cluster.eks-cluster.name
  addon_name   = "eks-node-monitoring-agent"
}

resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.eks-cluster.name
  addon_name   = "coredns"
  addon_version = "v1.11.4-eksbuild.2"

  depends_on = [
    aws_eks_node_group.eks-node
  ]
}

resource "aws_eks_addon" "eks-pod-identity-agent" {
  cluster_name = aws_eks_cluster.eks-cluster.name
  addon_name   = "eks-pod-identity-agent"
}