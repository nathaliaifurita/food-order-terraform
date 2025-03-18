resource "aws_lb" "food_order_lb" {
  name               = "food-order-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id]
  subnets            = var.private_subnet_ids
}

resource "aws_lb_target_group" "food_order_tg" {
  name     = "food-order-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.vpc.id

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.food_order_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.food_order_tg.arn
  }
}