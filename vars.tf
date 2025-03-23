variable "regionDefault" {
  default = "us-east-1"
}

variable "projectName" {
  default = "EKS-FOOD-ORDER-API"
}

variable "labRole" {
  default = "arn:aws:iam::198212171636:role/LabRole"
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
  default = "arn:aws:iam::198212171636:role/voclabs"
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

variable "POSTGRES_DB" {
  description = "Nome do banco de dados"
  type        = string
  default     = "foodorderdb"
}

variable "POSTGRES_USER" {
  description = "Username do banco de dados"
  type        = string
  default     = "postgres"
}

variable "POSTGRES_PASSWORD" {
  description = "Senha do banco de dados"
  type        = string
  default     = "postgres"
  sensitive   = true
}
