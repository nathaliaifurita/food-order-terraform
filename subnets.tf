# -------------------
# Public Subnets
# -------------------
resource "aws_subnet" "public_subnets" {
  for_each = {
    az1 = "us-east-1a"
    az2 = "us-east-1b"
  }

  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.main_vpc.cidr_block, 4, index(keys(each.key), each.key))
  availability_zone       = each.value
  map_public_ip_on_launch = true

  tags = {
    Name = "public-${each.key}"
  }
}

# -------------------
# Private Subnets
# -------------------
resource "aws_subnet" "private_subnets" {
  for_each = {
    az1 = "us-east-1a"
    az2 = "us-east-1b"
  }

  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.main_vpc.cidr_block, 4, index(keys(each.key), each.key) + 2)
  availability_zone = each.value

  tags = {
    Name = "private-${each.key}"
  }
}
