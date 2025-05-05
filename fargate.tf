resource "random_id" "suffix" {
  byte_length = 2
}

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
          "awslogs-group"         = aws_cloudwatch_log_group.auth_service.name
          "awslogs-region"        = var.regionDefault
          "awslogs-stream-prefix" = "auth"
        }
      }
    }
  ])
}

resource "aws_cloudwatch_log_group" "auth_service" {
  name              = "/ecs/auth-service-${data.random_id.suffix.hex}"
  retention_in_days = 14
}

# Esta parte de Load Balancer e Listener deve ser removida do local.tf para evitar duplicação
resource "aws_lb" "auth" {
  name               = "auth-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [for s in aws_subnet.public_subnets : s.id]

  tags = {
    Name = "auth-lb"
  }
}

resource "aws_lb_target_group" "auth_tg" {
  name     = "auth-tg-${data.random_id.suffix.hex}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.main.id

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

resource "aws_lb_listener" "auth" {
  load_balancer_arn = aws_lb.auth.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.auth_tg.arn
  }

  depends_on = [aws_lb.auth]
}

resource "aws_ecs_service" "auth_service" {
  name            = "auth-service"
  cluster         = aws_ecs_cluster.auth_cluster.id
  task_definition = aws_ecs_task_definition.auth_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

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

  tags = {
    Name = "auth-service"
  }
}
