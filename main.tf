module "vpc" {
  source                 = "./modules/vpc"
  create_vpc             = true
  create_subnets         = true
  create_security_group  = true
  project_name           = "my-app"

  availability_zones = ["us-east-1a", "us-east-1b"]

  security_group_ingress = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  tags = {
    Environment = "production"
    Owner       = "devops"
  }
}
