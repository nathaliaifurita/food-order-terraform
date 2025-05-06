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

locals {
  supported_azs = {
    az1 = "us-east-1a"
    az2 = "us-east-1b"
    az3 = "us-east-1c"
    az4 = "us-east-1d"
    az5 = "us-east-1f"
  }

  project_az_map = {
    auth      = "az1"
    pagamento = "az2"
    cardapio  = "az3"
    pedido    = "az4"
    usuario   = "az5"
  }

  project_names_map    = zipmap(["auth", "pagamento", "pedido", "cardapio", "usuario"], ["auth", "pagamento", "pedido", "cardapio", "usuario"])
  indexed_projects      = zipmap(var.projectNames, range(length(var.projectNames)))
  vpc_cidr              = "10.0.0.0/16"
  private_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnet_cidrs   = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

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
  for_each = local.project_names_map

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(local.vpc_cidr, 4, index(keys(local.supported_azs), local.project_az_map[each.key]))
  availability_zone       = local.supported_azs[local.project_az_map[each.key]]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-${each.key}"
  }
}

resource "aws_subnet" "private_subnets" {
  for_each = local.project_names_map

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(local.vpc_cidr, 4, index(keys(local.supported_azs), local.project_az_map[each.key]) + 10)
  availability_zone = local.supported_azs[local.project_az_map[each.key]]

  tags = {
    Name = "private-${each.key}"
  }
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
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnets["auth"].id  # Use uma chave existente do for_each de subnets

  tags = {
    Name = "nat-gateway"
  }

  depends_on = [aws_internet_gateway.main]
}

resource "random_id" "suffix" {
  byte_length = 2
}

