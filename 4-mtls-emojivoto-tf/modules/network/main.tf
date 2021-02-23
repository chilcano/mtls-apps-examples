resource "aws_vpc" "vpc" {
  count                = var.deploy_count
  cidr_block           = var.cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = {
    Name    = var.PlaygroundName
    Purpose = var.purpose
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.0.id

  tags = {
    Name    = var.PlaygroundName
    Purpose = var.purpose
  }
}

resource "aws_eip" "ngw_ip" {
  count = 0
}

resource "aws_nat_gateway" "ngw" {
  count         = 0
  allocation_id = aws_eip.ngw_ip.0.id
  subnet_id     = aws_subnet.public_subnets.0.id

  tags = {
    Name    = var.PlaygroundName
    Purpose = var.purpose
  }
}

resource "aws_subnet" "public_subnets" {
  count                   = var.required_subnets > 0 ? var.required_subnets : 1
  vpc_id                  = aws_vpc.vpc.0.id
  cidr_block              = cidrsubnet(var.cidr_block, 8, 10 + count.index)
  availability_zone       = element(data.aws_availability_zones.zones.names, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.PlaygroundName}-${count.index}"
    Purpose = var.purpose
    Tier    = "Public"    #So can find the type of subnet
    count   = count.index #So can find the first one
  }
}

resource "aws_subnet" "private_subnets" {
  count             = var.private_subnets
  vpc_id            = aws_vpc.vpc.0.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, 100 + count.index)
  availability_zone = element(data.aws_availability_zones.zones.names, count.index)

  tags = {
    Name    = "${var.PlaygroundName}-${count.index}"
    Purpose = var.purpose
    Tier    = "private"
  }
}