resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "Main IGW"
  }
}

resource "aws_eip" "nat" {
  for_each     = local.indexed_projects
  domain = "vpc"
}

resource "aws_nat_gateway" "main" {
  for_each     = local.indexed_projects
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public_subnets[each.key].id

  tags = {
    Name = "Main NAT Gateway"
  }

  depends_on = [aws_internet_gateway.main]
}
