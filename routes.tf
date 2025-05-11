# -------------------
# Public Route Table
# -------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "public-rt"
  }
}

# Associa subnets públicas à public RT
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# -------------------
# Private Route Table
# -------------------
resource "aws_route_table" "private" {
  count  = 2
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
  }

  tags = {
    Name = "private-rt"
  }
}

# Associa subnets privadas à private RT
resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

