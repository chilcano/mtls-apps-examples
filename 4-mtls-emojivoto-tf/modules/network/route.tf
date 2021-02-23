resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.0.id

  tags = {
    Name    = var.PlaygroundName
    Purpose = "Playground"
  }
}
resource "aws_route" "public_route_to_igw" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
  route_table_id         = aws_route_table.public_route_table.id
}

resource "aws_route_table" "private_route_table" {
  count  = var.private_subnets > 0 ? 1 : 0
  vpc_id = aws_vpc.vpc[count.index].id

  tags = {
    Name    = var.PlaygroundName
    Purpose = "Playground"
  }
}

resource "aws_route" "private_route_to_ngw" {
  count                  = var.private_subnets > 0 ? 1 : 0
  route_table_id         = aws_route_table.private_route_table.0.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw.0.id
}

resource "aws_route_table_association" "public_rt_assoc" {
  count          = var.required_subnets > 0 ? var.required_subnets : 1
  subnet_id      = element(aws_subnet.public_subnets.*.id, count.index)
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_rt_assoc" {
  count          = var.private_subnets
  subnet_id      = element(aws_subnet.private_subnets.*.id, count.index)
  route_table_id = aws_route_table.private_route_table.0.id
}
