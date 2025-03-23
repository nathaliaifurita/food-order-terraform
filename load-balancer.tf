resource "aws_lb" "food_order_lb" {
  name               = "food-order-lb"
  internal           = true
  load_balancer_type = "network"  # Mudando para NLB
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