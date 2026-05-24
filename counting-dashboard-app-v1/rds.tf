# -------------------------------------------------------
# DB Password (randomly generated)
# -------------------------------------------------------
resource "random_password" "db" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# -------------------------------------------------------
# RDS Subnet Group (requires 2 subnets in different AZs)
# -------------------------------------------------------
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = [aws_subnet.db_1.id, aws_subnet.db_2.id]

  tags = {
    Name    = "${var.project_name}-db-subnet-group"
    Project = var.project_name
  }
}

# -------------------------------------------------------
# RDS PostgreSQL Instance (Tier 3)
# -------------------------------------------------------
resource "aws_db_instance" "main" {
  identifier        = "${var.project_name}-postgres"
  engine            = "postgres"
  engine_version    = "15"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp2"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  password = random_password.db.result

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.database.id]

  multi_az            = false
  publicly_accessible = false
  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Name    = "${var.project_name}-postgres"
    Project = var.project_name
    Tier    = "database"
  }
}
