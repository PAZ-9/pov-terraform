# -------------------------------------------------------
# Dashboard Security Group (public subnet)
# -------------------------------------------------------
resource "aws_security_group" "dashboard" {
  name        = "${var.project_name}-dashboard-sg"
  description = "Allow SSH and app traffic to dashboard instance"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Dashboard app port"
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
    Name    = "${var.project_name}-dashboard-sg"
    Project = var.project_name
  }
}

# -------------------------------------------------------
# Database Security Group (db subnets — Tier 3)
# -------------------------------------------------------
resource "aws_security_group" "database" {
  name        = "${var.project_name}-database-sg"
  description = "Allow PostgreSQL traffic from counting instance only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "PostgreSQL from counting instance"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.counting.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-database-sg"
    Project = var.project_name
  }
}

# -------------------------------------------------------
# Counting Security Group (private subnet)
# -------------------------------------------------------
resource "aws_security_group" "counting" {
  name        = "${var.project_name}-counting-sg"
  description = "Allow SSH and app traffic from dashboard instance only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "SSH from dashboard"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.dashboard.id]
  }

  ingress {
    description     = "Counting app port from dashboard"
    from_port       = 9009
    to_port         = 9009
    protocol        = "tcp"
    security_groups = [aws_security_group.dashboard.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-counting-sg"
    Project = var.project_name
  }
}
