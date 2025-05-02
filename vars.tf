variable "regionDefault" {
  default = "us-east-1"
}

variable "projectNames" {
  default = "EKS-FOOD-ORDER-API"
  type    = list(string)
  default = ["EKS-FOOD-CARDAPIO", "EKS-FOOD-PEDIDO", "EKS-FOOD-USUARIO", "EKS-FOOD-PAGAMENTO"]
}

variable "labRole" {
  default = "arn:aws:iam::916083420257:role/LabRole"
}

variable "accessConfig" {
  default = "API_AND_CONFIG_MAP"
}

variable "nodeGroup" {
  default = "food-order-api-node-group"
}

variable "instanceType" {
  default = "t3.medium"
}

variable "principalArn" {
  default = "arn:aws:iam::916083420257:role/voclabs"
}

variable "policyArn" {
  default = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
}

variable "private_subnet_ids" {
  description = "Lista de subnets privadas"
  default     = []
}

variable "environment" {
  default = "Production-2"
}
