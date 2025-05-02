resource "aws_vpc" "main_vpc" {
  cidr_block = "172.31.0.0/16"

  tags = {
    Name        = "Main VPC"
    Environment = "production"
  }
}

data "aws_vpc" "main" {
  default = true  # ou use tags para identificar sua VPC específica
}

locals {
  vpc_id = data.aws_vpc.main.id
}

resource "aws_subnet" "public_subnets" {
  count                   = 2
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = cidrsubnet("172.31.0.0/16", 4, count.index + 2)
  availability_zone       = element(["us-east-1a", "us-east-1b"], count.index)
  map_public_ip_on_launch = true

  tags = {
    Name        = "Public Subnet ${count.index + 1}"
    Environment = "public"
    "kubernetes.io/cluster/${var.projectNames}" = "shared"
    "kubernetes.io/role/elb"                   = "1"
  }
}

resource "aws_subnet" "private_subnets" {
  count             = 2
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = cidrsubnet("172.31.0.0/16", 4, count.index)
  availability_zone = element(["us-east-1a", "us-east-1b"], count.index)

  tags = {
    Name        = "Private Subnet ${count.index + 1}"
    Environment = "private"
    "kubernetes.io/cluster/${var.projectNames}" = "shared"
    "kubernetes.io/role/internal-elb"         = "1"
  }
}
