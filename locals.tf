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
  project_names       = var.projectNames
  indexed_projects    = zipmap(var.projectNames, range(length(var.projectNames)))
  availability_zones  = data.aws_availability_zones.available.names
  vpc_cidr            = "172.31.0.0/16"
  private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

###############################
# DATA SOURCES
###############################

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_vpc" "main" {
  default = true
}

###############################
# VPC
###############################

resource "aws_vpc" "main_vpc" {
  cidr_block = local.vpc_cidr

  tags = {
    Name        = "Main VPC"
    Environment = var.environment
  }
}

###############################
# SUBNETS
###############################

resource "aws_subnet" "public_subnets" {
  for_each = local.indexed_projects.project_names

  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = cidrsubnet(local.vpc_cidr, 4, index(keys(local.supported_azs), local.project_az_map[each.key]))
  availability_zone       = local.supported_azs[local.project_az_map[each.key]]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-${each.key}"
  }
}

resource "aws_subnet" "private_subnets" {
  for_each = local.indexed_projects.project_names

  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = cidrsubnet(local.vpc_cidr, 4, index(keys(local.supported_azs), local.project_az_map[each.key]) + 2)
  availability_zone = local.supported_private_azs[local.project_az_map[each.key]]

  tags = {
    Name = "private-${each.key}"
  }
}

###############################
# LOAD BALANCERS (NLB por projeto)
###############################

resource "aws_lb" "food_order_lb" {
  for_each = local.indexed_projects

  name               = "food-order-lb-${each.key}"
  internal           = true
  load_balancer_type = "network"
  subnets            = [aws_subnet.public_subnets[each.key].id]

  enable_deletion_protection = false

  tags = {
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "food_order_tg" {
  for_each    = local.indexed_projects
  name        = "food-order-tg-${each.key}"
  port        = 80
  protocol    = "TCP"
  vpc_id      = aws_vpc.main_vpc.id
  target_type = "ip"

  health_check {
    protocol            = "TCP"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 30
  }
}

resource "aws_lb_listener" "http" {
  for_each = local.indexed_projects

  load_balancer_arn = aws_lb.food_order_lb[each.key].arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.food_order_tg[each.key].arn
  }
}

###############################
# EXTRA: AUTH LB (Application LB, exemplo separado)
###############################

resource "aws_lb" "auth_lb" {
  name               = "auth-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.fargate_sg.id]
  subnets            = [aws_subnet.private_subnets["auth"].id]

  enable_deletion_protection = false

  tags = {
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "auth_tg" {
  name        = "auth-tg"
  port        = 4000
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.main.id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/health"
    timeout             = 5
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "auth" {
  load_balancer_arn = aws_lb.auth_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.auth_tg.arn
  }
}
