resource "aws_security_group" "sg" {
  name        = "SG-${var.projectName}"
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

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}