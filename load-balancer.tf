resource "aws_lb" "food_order_lb" {
  name               = "food-order-lb"
  internal           = true
  load_balancer_type = "network"
  subnets            = aws_subnet.private_subnets[*].id

  enable_deletion_protection = false

  tags = {
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "food_order_tg" {
  name        = "food-order-tg"
  port        = 80
  protocol    = "TCP"  # Mudando para TCP para NLB
  vpc_id      = aws_vpc.main_vpc.id
  target_type = "ip"

  health_check {
    protocol            = "TCP"
    port               = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 30
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.food_order_lb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.food_order_tg.arn
  }
}

# Load Balancer para o serviço de autenticação
resource "aws_lb" "auth_lb" {
  name               = "auth-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.fargate_sg.id]
  subnets           = data.aws_subnets.private.ids
}

# Target Group para o serviço de autenticação
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
    matcher            = "200"
    path               = "/health"
    timeout            = 5
    unhealthy_threshold = 2
  }
}

# Listener para o Load Balancer
resource "aws_lb_listener" "auth" {
  load_balancer_arn = aws_lb.auth_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.auth_tg.arn
  }
}

# Data source atualizado para subnets
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  filter {
    name   = "tag:Tier"
    values = ["Private"]  # Ajuste conforme suas tags
  }
}
