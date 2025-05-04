resource "aws_route_table" "public" {
  for_each = local.indexed_projects
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.main[each.key].id
  }

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table" "private" {
  for_each = local.indexed_projects
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[each.key].id
  }

  tags = {
    Name = "Private Route Table"
  }
}

resource "aws_route_table_association" "public" {
  for_each       = local.indexed_projects
  count          = 2
  subnet_id      = aws_subnet.public_subnets[each.key].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  for_each       = local.indexed_projects
  count          = 2
  subnet_id      = aws_subnet.private_subnets[each.key].id
  route_table_id = aws_route_table.private.id
}

