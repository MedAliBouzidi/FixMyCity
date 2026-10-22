resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "${var.group_prefix}-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.group_prefix}-igw" }
}

# =========================================================
# 1. PUBLIC SUBNETS (/27) — Hosts ALB, NAT GW & Frontend EC2
# =========================================================
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/27"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
  tags                    = { Name = "${var.group_prefix}-public-subnet-1" }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/27"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true
  tags                    = { Name = "${var.group_prefix}-public-subnet-2" }
}

# =========================================================
# 2. PRIVATE BACKEND APP SUBNETS (/27) — Hosts Backend EC2
# =========================================================
resource "aws_subnet" "private_backend_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.10.0/27"
  availability_zone = "${var.aws_region}a"
  tags              = { Name = "${var.group_prefix}-private-backend-subnet-1" }
}

resource "aws_subnet" "private_backend_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/27"
  availability_zone = "${var.aws_region}b"
  tags              = { Name = "${var.group_prefix}-private-backend-subnet-2" }
}

# =========================================================
# 3. PRIVATE DB SUBNETS (/27) — Hosts RDS MySQL
# =========================================================
resource "aws_subnet" "private_db_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.20.0/27"
  availability_zone = "${var.aws_region}a"
  tags              = { Name = "${var.group_prefix}-private-db-subnet-1" }
}

resource "aws_subnet" "private_db_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.21.0/27"
  availability_zone = "${var.aws_region}b"
  tags              = { Name = "${var.group_prefix}-private-db-subnet-2" }
}

# =========================================================
# 4. OUTBOUND ACCESS: NAT GATEWAY (Placed in Public Subnet 2 per diagram)
# =========================================================
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags   = { Name = "${var.group_prefix}-nat-eip" }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_2.id
  tags          = { Name = "${var.group_prefix}-nat-gw" }
  depends_on    = [aws_internet_gateway.igw]
}

# =========================================================
# 5. ROUTE TABLES & S3 ENDPOINT
# =========================================================
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "${var.group_prefix}-public-rt" }
}

resource "aws_route_table_association" "pub_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "pub_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }
  tags = { Name = "${var.group_prefix}-private-rt" }
}

resource "aws_route_table_association" "priv_be_1" {
  subnet_id      = aws_subnet.private_backend_1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "priv_be_2" {
  subnet_id      = aws_subnet.private_backend_2.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "priv_db_1" {
  subnet_id      = aws_subnet.private_db_1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "priv_db_2" {
  subnet_id      = aws_subnet.private_db_2.id
  route_table_id = aws_route_table.private_rt.id
}

# S3 VPC Endpoint (Gateway type is free and routes S3 traffic directly)
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.public_rt.id, aws_route_table.private_rt.id]
  tags              = { Name = "${var.group_prefix}-s3-endpoint" }
}
