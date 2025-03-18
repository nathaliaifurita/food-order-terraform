data "aws_vpc" "vpc" {
  cidr_block = "172.31.0.0/16"
}

data "aws_subnets" "private_subnets" {
  filter {
    name   = "tag:Environment"
    values = ["private"]
  }
}

data "aws_subnet" "private_subnet" {
  for_each = toset(data.aws_subnets.private_subnets.ids)
  id       = each.value
}

