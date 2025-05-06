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
  name              = "/ecs/auth-service-${random_id.suffix.hex}"
  retention_in_days = 14
}

# Esta parte de Load Balancer e Listener deve ser removida do local.tf para evitar duplicação
resource "aws_lb" "food_order_lb" {
  name               = "food-order-lb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [for s in aws_subnet.public_subnets : s.id]

  security_groups    = [aws_security_group.sg.id]

  enable_deletion_protection = false

  tags = {
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "food_order_tg" {
  name        = "food-order-tg-${random_id.suffix.hex}"
  port        = 80                     # Porta que o container escuta
  protocol    = "TCP"                   # Importante: TCP, não HTTP
  target_type = "ip"
  vpc_id      = aws_vpc.main.id

  health_check {
    protocol = "TCP"                   # Health check simples
  }

  tags = {
    Name = "auth-target-group"
  }
}

resource "aws_lb_listener" "auth" {
  load_balancer_arn = aws_lb.food_order_lb.arn
  port              = 4000              # Porta pública
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.food_order_tg-${random_id.suffix.hex}.arn
  }

  depends_on = [aws_lb_target_group.food_order_tg-${random_id.suffix.hex}]
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
    target_group_arn = aws_lb_target_group.food_order_tg-${random_id.suffix.hex}.arn
    container_name   = "auth-container"
    container_port   = 4000
  }

  tags = {
    Name = "auth-service"
  }
}
