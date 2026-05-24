##########################################################
# vpc
##########################################################

resource "aws_vpc" "counting-dashboard-vpc" {
  cidr_block           = var.address_space
  enable_dns_hostnames = true

  tags = {
    name        = "${var.prefix}-vpc-${var.region}"
    environment = "${var.environment}"
  }
}

##########################################################
# dashboard-subnet
##########################################################

resource "aws_subnet" "dashboard-subnet" {
  vpc_id                  = aws_vpc.counting-dashboard-vpc.id
  cidr_block              = var.dashboard-subnet_prefix
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "${var.prefix}-dashboard-public-subnet"
  }
}

##########################################################
# counting-subnet
##########################################################

resource "aws_subnet" "counting-subnet" {
  vpc_id            = aws_vpc.counting-dashboard-vpc.id
  cidr_block        = var.counting-subnet_prefix
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "${var.prefix}-counting-private-subnet"
  }
}

##########################################################
# internet gateway
##########################################################

resource "aws_internet_gateway" "counting-dashboard" {
  vpc_id = aws_vpc.counting-dashboard-vpc.id

  tags = {
    Name = "${var.prefix}-internet-gateway"
  }
}

##########################################################
# nat gateway
##########################################################

resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "${var.prefix}-nat-eip"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.dashboard-subnet.id # PUBLIC subnet

  tags = {
    Name = "${var.prefix}-nat-gateway"
  }

  depends_on = [aws_internet_gateway.counting-dashboard]
}

##########################################################
# dashboard route table & rt association
##########################################################

resource "aws_route_table" "dashboard-rt" {
  vpc_id = aws_vpc.counting-dashboard-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.counting-dashboard.id
  }
  tags = {
    Name = "${var.prefix}-dashboard-rt"
  }
}

resource "aws_route_table_association" "dashboard-rt-asso" {
  subnet_id      = aws_subnet.dashboard-subnet.id
  route_table_id = aws_route_table.dashboard-rt.id
}

##########################################################
# counting route table & rt association
##########################################################

resource "aws_route_table" "counting-rt" {
  vpc_id = aws_vpc.counting-dashboard-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "${var.prefix}-counting-rt"
  }
}

resource "aws_route_table_association" "counting-rt-asso" {
  subnet_id      = aws_subnet.counting-subnet.id
  route_table_id = aws_route_table.counting-rt.id
}

##########################################################
# elastic ip for dashboard instance
##########################################################

resource "aws_eip" "counting-dashboard" {
  instance = aws_instance.dashboard-instance.id
  domain   = "vpc"
}

resource "aws_eip_association" "counting-dashboard" {
  instance_id   = aws_instance.dashboard-instance.id
  allocation_id = aws_eip.counting-dashboard.id
}

##########################################################
# dashboard security group
##########################################################

resource "aws_security_group" "dashboard-sg" {
  name = "${var.prefix}-dashboard-security-group"

  vpc_id = aws_vpc.counting-dashboard-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9009
    to_port     = 9009
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-dashboard-security-group"
  }
}

##########################################################
# counting security group
##########################################################

resource "aws_security_group" "counting-sg" {
  name = "${var.prefix}-counting-security-group"

  vpc_id = aws_vpc.counting-dashboard-vpc.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.dashboard-sg.id]
  }

  ingress {
    from_port       = 9009
    to_port         = 9009
    protocol        = "tcp"
    security_groups = [aws_security_group.dashboard-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-counting-security-group"
  }
}


