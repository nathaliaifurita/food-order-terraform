resource "aws_ecs_cluster" "auth_cluster" {
  name = "auth-cluster"
}

resource "aws_ecs_task_definition" "auth_task" {
  family                   = "auth-task"
  requires_compatibilities = ["FARGATE"]
  network_mode            = "awsvpc"
  cpu                     = 256
  memory                  = 512
  execution_role_arn      = aws_iam_role.ecs_execution_role.arn
  task_role_arn           = aws_iam_role.ecs_task_role.arn
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture       = "ARM64"  # Importante: especificando ARM64
  }

  container_definitions = jsonencode([
    {
      name  = "auth-container"
      image = "diegogl12/auth_cpf:latest"
      portMappings = [
        {
          containerPort = 4000  # Porta que sua aplicação Phoenix/Elixir escuta
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

resource "aws_ecs_service" "auth_service" {
  name            = "auth-service"
  cluster         = aws_ecs_cluster.auth_cluster.id
  task_definition = aws_ecs_task_definition.auth_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = local.private_subnet_ids
    security_groups  = [aws_security_group.fargate_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.auth_tg.arn
    container_name   = "auth-container"
    container_port   = 4000
  }
}