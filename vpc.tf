resource "aws_vpc" "main_vpc" {

  cidr_block       = "10.0.0.0/20"
  instance_tenancy = "default"

  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-${terraform.workspace}-vpc-${random_id.name.hex}"
  }
}

# --- Subnets ---

resource "aws_subnet" "vpc_private_subnet_1" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "${var.region}a" # us-east-1a

  tags = {
    Name = "${var.project_name}-${terraform.workspace}-private-subnet-1-${var.region}a-${random_id.name.hex}"
  }
}

resource "aws_subnet" "vpc_public_subnet_1" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "${var.region}a" # us-east-1a

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-${terraform.workspace}-public-subnet-1-${var.region}a-${random_id.name.hex}"
  }
}

resource "aws_subnet" "vpc_private_subnet_2" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = "${var.region}b" # us-east-1b

  tags = {
    Name = "${var.project_name}-${terraform.workspace}-private-subnet-2-${var.region}b-${random_id.name.hex}"
  }
}

resource "aws_subnet" "vpc_public_subnet_2" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.13.0/24"
  availability_zone = "${var.region}b" # us-east-1b

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-${terraform.workspace}-public-subnet-2-${var.region}b-${random_id.name.hex}"
  }
}

# --- Internet Gateway ---

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.project_name}-${terraform.workspace}-igw-${random_id.name.hex}"
  }
}

# --- Elastic IP ---

resource "aws_eip" "eip_1" {
  vpc = true

  tags = {
    Name = "${var.project_name}-${terraform.workspace}-eip-nat-1-${random_id.name.hex}"
  }

}

resource "aws_eip" "eip_2" {
  vpc = true

  tags = {
    Name = "${var.project_name}-${terraform.workspace}-eip-nat-2-${random_id.name.hex}"
  }

}

# --- Nat Gateway ---

resource "aws_nat_gateway" "nat_gateway_1" {
  allocation_id = aws_eip.eip_1.id
  subnet_id     = aws_subnet.vpc_public_subnet_1.id

  tags = {
    Name = "${var.project_name}-${terraform.workspace}-nat-gw-1-${random_id.name.hex}"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat_gateway_2" {
  allocation_id = aws_eip.eip_2.id
  subnet_id     = aws_subnet.vpc_public_subnet_2.id

  tags = {
    Name = "${var.project_name}-${terraform.workspace}-nat-gw-2-${random_id.name.hex}"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}

# --- Route Tables ---

resource "aws_route_table" "public_subnet_routes" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project_name}-${terraform.workspace}-public-route-table-${random_id.name.hex}"
  }
}

resource "aws_route_table_association" "public_subnet_1_routes_association" {
  subnet_id      = aws_subnet.vpc_public_subnet_1.id
  route_table_id = aws_route_table.public_subnet_routes.id
}

resource "aws_route_table_association" "public_subnet_2_routes_association" {
  subnet_id      = aws_subnet.vpc_public_subnet_2.id
  route_table_id = aws_route_table.public_subnet_routes.id
}

resource "aws_route_table" "private_subnet_1_routes" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_1.id
  }

  tags = {
    Name = "${var.project_name}-${terraform.workspace}-private-route-table-1-${random_id.name.hex}"
  }
}

resource "aws_route_table_association" "private_subnet_1_routes_association" {
  subnet_id      = aws_subnet.vpc_private_subnet_1.id
  route_table_id = aws_route_table.private_subnet_1_routes.id
}

resource "aws_route_table" "private_subnet_2_routes" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_2.id
  }

  tags = {
    Name = "${var.project_name}-${terraform.workspace}-private-route-table-2-${random_id.name.hex}"
  }
}

resource "aws_route_table_association" "private_subnet_2_routes_association" {
  subnet_id      = aws_subnet.vpc_private_subnet_2.id
  route_table_id = aws_route_table.private_subnet_2_routes.id
}
