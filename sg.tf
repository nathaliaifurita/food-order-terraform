resource "aws_security_group" "sg" {
  for_each    = toset(var.projectNames)
  name        = "SG-${each.key}"
  description = "Security Group do Food Order API"
  vpc_id      = aws_vpc.main_vpc.id

  # Permitir tráfego do API Gateway para o Load Balancer
  ingress {
    description = "HTTP from API Gateway"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main_vpc.cidr_block]
  }

  # Permitir comunicação entre nodes do EKS
  ingress {
    description = "Allow nodes to communicate with each other"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  # Permitir comunicação do Load Balancer com os nodes
  ingress {
    description = "Allow LB to nodes communication"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "Allow worker nodes to communicate with control plane"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main_vpc.cidr_block]
  }

  ingress {
    description = "Kubelet API"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    self        = true
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "fargate_sg" {
  name        = "fargate-auth-sg"
  description = "Security group for Auth Fargate service"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description = "Allow inbound from ALB"
    from_port   = 4000
    to_port     = 4000
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main_vpc.main.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "fargate-auth-sg"
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "alb-auth-sg"
  description = "Security group for Auth ALB"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description = "Allow inbound HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main_vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-auth-sg"
  }
}