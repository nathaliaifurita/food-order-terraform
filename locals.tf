###############################
# VARIABLES (assumindo var.projectNames já definido)
###############################

variable "projectNames" {
  type    = list(string)
  default = ["cardapio", "pagamento", "pedido", "usuario", "auth"]
}

variable "environment" {
  type    = string
  default = "production"
}

variable "regionDefault" {
  default = "us-east-1"
}

variable "labRole" {
  default = "arn:aws:iam::198212171636:role/LabRole"
}

variable "accessConfig" {
  default = "API_AND_CONFIG_MAP"
}

variable "instanceType" {
  default = "t3.medium"
}

variable "principalArn" {
  default = "arn:aws:iam::198212171636:role/voclabs"
}

variable "policyArnEKSClusterAdminPolicy" {
  default = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
}

###############################
# LOCALS
###############################
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}

###############################
# SUBNETS
###############################

resource "aws_subnet" "public_subnets" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet("10.0.1.0/24", 4, count.index)
  availability_zone       = element(["us-east-1a", "us-east-1b"], count.index)
  map_public_ip_on_launch = true

  tags = merge (
    {
      Name        = "Public Subnet ${count.index + 1}"
      Environment = "public"
      "kubernetes.io/role/elb" = "1"
    },
    { for name in var.projectNames : "kubernetes.io/cluster/${name}" => "shared" }
  )
}

resource "aws_subnet" "private_subnets" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet("10.0.2.0/24", 4, count.index + 2)
  availability_zone = element(["us-east-1a", "us-east-1b"], count.index)

  tags = merge(
    {
      Name                              = "Private Subnet ${count.index + 1}"
      Environment                       = "private"
      "kubernetes.io/role/internal-elb" = "1"
    },
    { for name in var.projectNames : "kubernetes.io/cluster/${name}" => "shared" }
  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Main IGW"
  }
}

resource "aws_eip" "nat" {
  vpc = true

  tags = {
    Name = "nat-eip"
  }
}

resource "aws_nat_gateway" "nat" {
  count = 2
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnets[count.index].id

  tags = {
    Name = "nat-gateway"
  }

  depends_on = [aws_internet_gateway.main]
}

resource "random_id" "suffix" {
  byte_length = 2
}

