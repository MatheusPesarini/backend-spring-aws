resource "aws_db_subnet_group" "db" {
  name       = "${var.project_name}-${var.environment}-db-subnets"
  subnet_ids = [for s in aws_subnet.private : s.id]
  tags = {
    Name = "${var.project_name}-${var.environment}-db-subnets"
  }
}

resource "aws_db_instance" "postgres" {
  identifier              = "${var.project_name}-${var.environment}-pg"
  allocated_storage       = 20
  max_allocated_storage   = 50
  engine                  = "postgres"
  engine_version          = "16.3"
  instance_class          = var.db_instance_class
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.db.name
  vpc_security_group_ids  = [aws_security_group.db_sg.id]
  skip_final_snapshot     = true
  deletion_protection     = false
  multi_az                = false
  publicly_accessible     = false
  storage_encrypted       = true
  backup_retention_period = 1
  apply_immediately       = true
  tags = {
    Name        = "${var.project_name}-${var.environment}-postgres"
    Environment = var.environment
  }
}

