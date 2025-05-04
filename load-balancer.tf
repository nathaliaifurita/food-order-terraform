data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  # Ajuste os filtros conforme suas tags
  filter {
    name   = "tag:Name"
    values = ["*Private*", "*private*"]  # Case insensitive
  }
}

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = data.aws_vpc.main.id
  
  # Usar diferentes blocos CIDR para cada subnet
  cidr_block        = "172.31.${count.index + 48}.0/24"  # Ajuste conforme sua VPC
  
  # Usar diferentes AZs
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "private-subnet-${count.index + 1}"
    Tier = "Private"
  }
}
