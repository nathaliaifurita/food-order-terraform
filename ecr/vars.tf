variable "repository_name" {
  description = "Nome do repositório ECR"
  type        = string
}

variable "tags" {
  description = "Tags aplicadas ao repositório"
  type        = map(string)
  default     = {}
}
