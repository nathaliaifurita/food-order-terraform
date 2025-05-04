###############################
# VARIABLES (assumindo var.projectNames já definido)
###############################

variable "projectNames" {
  type = list("cardapio", "pagamento", "pedido", "usuario")
}

variable "environment" {
  type    = string
  default = "production"
}

###############################
# LOCALS
###############################

locals {
  project_names       = var.projectNames
  indexed_projects    = zipmap(var.projectNames, range(length(var.projectNames)))
  availability_zones  = data.aws_availability_zones.available.names
  vpc_cidr            = "172.31.0.0/16"
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
  for_each = local.indexed_projects

  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = cidrsubnet(local.vpc_cidr, 4, each.value)
  availability_zone       = element(local.availability_zones, each.value % length(local.availability_zones))
  map_public_ip_on_launch = true

  tags = {
    Name                             = "Public Subnet ${each.key}"
    Environment                      = "public"
    "kubernetes.io/cluster/${each.key}" = "shared"
    "kubernetes.io/role/elb"         = "1"
  }
}

resource "aws_subnet" "private_subnets" {
  for_each = local.indexed_projects

  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = cidrsubnet(local.vpc_cidr, 4, each.value + 10)
  availability_zone = element(local.availability_zones, each.value % length(local.availability_zones))

  tags = {
    Name                             = "Private Subnet ${each.key}"
    Environment                      = "private"
    "kubernetes.io/cluster/${each.key}" = "shared"
    "kubernetes.io/role/internal-elb"  = "1"
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
  subnets            = aws_subnet.private_subnets["auth"].id

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
