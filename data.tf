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
  for_each                = toset(var.projectNames)
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = cidrsubnet("172.31.0.0/16", 4, each.key)
  availability_zone       = element(["us-east-1a", "us-east-1b"], each.key % 2)
  map_public_ip_on_launch = true

  tags = {
    Name         = "Public Subnet ${each.key}"
    Environment  = "public"
    "kubernetes.io/cluster/${each.key}"        = "shared"
    "kubernetes.io/role/elb"                   = "1"
  }
}

resource "aws_subnet" "private_subnets" {
  for_each          = toset(var.projectNames)
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = cidrsubnet("172.31.0.0/16", 4, each.key) 
  availability_zone = element(["us-east-1a", "us-east-1b"], each.key % 2)

  tags = {
    Name        = "Private Subnet ${each.key}"
    Environment = "private"
    "kubernetes.io/cluster/${each.key}"       = "shared"
    "kubernetes.io/role/internal-elb"         = "1"
  }
}
