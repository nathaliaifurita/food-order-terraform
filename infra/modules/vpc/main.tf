// Criação ou uso de VPC
data "aws_vpc" "existing_vpc" {
  count = var.create_vpc ? 0 : 1

  filter {
    name   = "cidr-block"
    values = [var.vpc_cidr_block]
  }
}

resource "aws_vpc" "main_vpc" {
  count      = var.create_vpc ? 1 : 0
  cidr_block = var.vpc_cidr_block

  tags = merge(var.tags, {
    Name = "${var.project_name}-vpc"
  })
}

locals {
  vpc_id = var.create_vpc ? aws_vpc.main_vpc[0].id : data.aws_vpc.existing_vpc[0].id
}

// Subnets públicas
data "aws_subnet" "existing_public" {
  count = var.create_subnets ? 0 : 2

  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }

  filter {
    name   = "availability-zone"
    values = [element(var.availability_zones, count.index)]
  }
}

resource "aws_subnet" "public" {
  count                   = var.create_subnets ? 2 : 0
  vpc_id                  = local.vpc_id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 4, count.index + 2)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-public-subnet-${count.index + 1}"
  })
}

// Subnets privadas
data "aws_subnet" "existing_private" {
  count = var.create_subnets ? 0 : 2

  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }

  filter {
    name   = "availability-zone"
    values = [element(var.availability_zones, count.index)]
  }
}

resource "aws_subnet" "private" {
  count             = var.create_subnets ? 2 : 0
  vpc_id            = local.vpc_id
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 4, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = merge(var.tags, {
    Name = "${var.project_name}-private-subnet-${count.index + 1}"
  })
}

locals {
  private_subnet_ids = var.create_subnets ? aws_subnet.private[*].id : data.aws_subnet.existing_private[*].id
  public_subnet_ids  = var.create_subnets ? aws_subnet.public[*].id  : data.aws_subnet.existing_public[*].id
}

resource "aws_security_group" "main_sg" {
  count  = var.create_security_group ? 1 : 0
  name   = "${var.project_name}-main-sg"
  vpc_id = local.vpc_id

  description = "Security group for ${var.project_name}"

  tags = merge(var.tags, {
    Name = "${var.project_name}-sg"
  })
}

resource "aws_security_group_rule" "ingress_rules" {
  count             = var.create_security_group && length(var.security_group_ingress) > 0 ? length(var.security_group_ingress) : 0
  type              = "ingress"
  from_port         = var.security_group_ingress[count.index].from_port
  to_port           = var.security_group_ingress[count.index].to_port
  protocol          = var.security_group_ingress[count.index].protocol
  cidr_blocks       = var.security_group_ingress[count.index].cidr_blocks
  security_group_id = aws_security_group.main_sg[0].id
}

resource "aws_security_group_rule" "egress_rules" {
  count             = var.create_security_group && length(var.security_group_egress) > 0 ? length(var.security_group_egress) : 0
  type              = "egress"
  from_port         = var.security_group_egress[count.index].from_port
  to_port           = var.security_group_egress[count.index].to_port
  protocol          = var.security_group_egress[count.index].protocol
  cidr_blocks       = var.security_group_egress[count.index].cidr_blocks
  security_group_id = aws_security_group.main_sg[0].id
}

locals {
  security_group_id = var.create_security_group ? aws_security_group.main_sg[0].id : null
}

//resource "aws_db_subnet_group" "rds_subnet_group" {
//  count      = var.create_rds ? 1 : 0
//  name       = "${var.project_name}-rds-subnet-group"
//  subnet_ids = local.private_subnet_ids
//
//  tags = merge(var.tags, {
//    Name = "${var.project_name}-rds-subnet-group"
//  })
//}

//resource "aws_db_instance" "rds_instance" {
//  count                   = var.create_rds ? 1 : 0
//  identifier              = "${var.project_name}-rds"
//  instance_class          = var.rds_instance_class
//  allocated_storage       = var.rds_allocated_storage
//  engine                  = var.rds_engine
//  engine_version          = var.rds_engine_version
//  username                = var.rds_username
//  password                = var.rds_password
//  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group[0].name
//  vpc_security_group_ids  = var.create_security_group ? [aws_security_group.main_sg[0].id] : []
//  skip_final_snapshot     = var.rds_skip_final_snapshot
//  publicly_accessible     = false
//  deletion_protection     = var.rds_deletion_protection
//  multi_az                = var.rds_multi_az
//  backup_retention_period = var.rds_backup_retention_period
//  storage_encrypted       = var.rds_storage_encrypted
//  apply_immediately       = var.rds_apply_immediately
//
//  tags = merge(var.tags, {
//    Name = "${var.project_name}-rds"
//  })
//}


