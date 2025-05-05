resource "aws_ecs_cluster" "auth_cluster" {
  name = "auth-cluster"
}

resource "aws_ecs_task_definition" "auth_task" {
  family                   = "auth-task"
  requires_compatibilities = ["FARGATE"]
  network_mode            = "awsvpc"
  cpu                     = 256
  memory                  = 512
  execution_role_arn      = "arn:aws:iam::198212171636:role/ecsTaskExecutionRole"
  task_role_arn           = "arn:aws:iam::198212171636:role/ecsTaskExecutionRole"

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture       = "ARM64"
  }

  container_definitions = jsonencode([
    {
      name  = "auth-container"
      image = "diegogl12/auth_cpf:latest"
      portMappings = [
        {
          containerPort = 4000
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "PORT"
          value = "4000"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/auth-service"
          "awslogs-region"        = var.regionDefault
          "awslogs-stream-prefix" = "auth"
        }
      }
    }
  ])
}

resource "aws_cloudwatch_log_group" "auth_service" {
  name              = "/ecs/auth-service"
  retention_in_days = 14
}

resource "aws_lb_listener" "auth" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.auth_tg.arn
  }

  depends_on = [aws_lb.main]
}

resource "aws_ecs_service" "auth_service" {
  name            = "auth-service"
  cluster         = aws_ecs_cluster.auth_cluster.id
  task_definition = aws_ecs_task_definition.auth_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  # Adiciona dependência explícita
  depends_on = [aws_lb_listener.auth]

  network_configuration {
    subnets          = [for subnet in values(aws_subnet.private_subnets) : subnet.id]
    security_groups  = [aws_security_group.fargate_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.auth_tg.arn
    container_name   = "auth-container"
    container_port   = 4000
  }

  resource "aws_lb_target_group" "auth_tg" {
  name     = "auth-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main_vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "auth-target-group"
  }
}

}
