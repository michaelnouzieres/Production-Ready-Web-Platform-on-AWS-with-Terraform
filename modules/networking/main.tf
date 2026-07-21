
#### Creating VPC and Subnets

resource "aws_vpc" "main" {
  cidr_block       = var.cidr_block
  enable_dns_support   = true  # Added
  enable_dns_hostnames = true  # Added Added
  

  tags = {
    Name = "wordpress_webapp"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  count = length(var.availability_zones)
  cidr_block        = cidrsubnet(var.cidr_block, 8, count.index) 
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "public_subnet_${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  count = length(var.availability_zones)
  cidr_block        = cidrsubnet(var.cidr_block, 8, count.index+10) 
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "private_subnet_${count.index + 1}"
  }
}

resource "aws_subnet" "private_db" {
  vpc_id            = aws_vpc.main.id
  count = length(var.availability_zones)
  cidr_block        = cidrsubnet(var.cidr_block, 8, count.index+15) 
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "private_subnet_db${count.index + 1}"
  }
}


#### Creating IGW

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw"
  }
}

### Creating Elastic IP

resource "aws_eip" "nat" {
  count = length(var.availability_zones)
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "nat-gateway-eip-${count.index+1}"
  }
}

#### Creating NAT GW

resource "aws_nat_gateway" "natgw" {
  count = length(var.availability_zones)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "gw NAT-${count.index+1}"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}


#### Creating Route Tables and Routes

######## Public Internet Routing

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "public-route-table"
  }
}


resource "aws_route" "internet_access" {
  route_table_id            = aws_route_table.public_rt.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
  
}

resource "aws_route_table_association" "public_association" {
  count = length(var.availability_zones)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

####### Private Routing

resource "aws_route_table" "private_rt" {
  count = length(var.availability_zones)
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "private-route-table-${count.index+1}"
  }
  
}

resource "aws_route" "private_nat" {
  count = length(var.availability_zones)
  route_table_id = aws_route_table.private_rt[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.natgw[count.index].id
}

resource "aws_route_table_association" "private_association" {
  count = length(var.availability_zones)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_rt[count.index].id
}

####### Isolated DB Routing (No NAT Gateway)


resource "aws_route_table" "db_isolated_rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "db-isolated-route-table"
  }
}


resource "aws_route_table_association" "private_db_association" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.private_db[count.index].id
  route_table_id = aws_route_table.db_isolated_rt.id
}
