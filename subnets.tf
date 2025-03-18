data "aws_subnets" "private_subnets" {
  filter {
    name   = "tag:Environment"
    values = ["private"]
  }
}

data "aws_subnets" "public_subnets" {
  filter {
    name   = "tag:Environment"
    values = ["public"]
  }
}

variable "private_subnet_ids" {
  description = "Lista de subnets privadas"
  default     = []
}

variable "public_subnet_ids" {
  description = "Lista de subnets públicas"
  default     = []
}