provider "aws" {
  region = var.regionDefault
}

data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.eks_cluster.name
}

provider "kubernetes" {
  host                   = aws_eks_cluster.eks_cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.eks_cluster.name]
    command     = "aws"
  }
}

data "aws_eks_cluster" "eks_cluster" {
  name = var.projectName
}

data "aws_eks_cluster_auth" "eks_auth" {
  name = var.projectName
}

data "aws_db_instance" "rds_postgres" {
  db_instance_identifier = var.RDS_INSTANCE
}
