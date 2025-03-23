provider "aws" {
  region = var.regionDefault
}

data "aws_eks_cluster" "eks_cluster" {
  name = var.projectName
}

data "aws_eks_cluster_auth" "eks_auth" {
  name = var.projectName
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks_cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.eks_cluster.name]
  }
}