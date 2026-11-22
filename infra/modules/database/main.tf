locals {
  ssm_prefix = "/${var.project_name}/${var.environment}/db"
}

resource "random_password" "db" {
  length           = 24
  special          = true
  override_special = "!#$%^&*()-_=+"
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = var.db_subnet_ids
}

resource "aws_db_instance" "main" {
  identifier = "${var.project_name}-${var.environment}-mysql"

  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = var.db_instance_class
  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = var.db_name
  username = var.db_username
  password = random_password.db.result

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.database_security_group_id]
  publicly_accessible    = false

  multi_az            = false
  monitoring_interval = 0
  skip_final_snapshot = true
}

resource "aws_ssm_parameter" "username" {
  name      = "${local.ssm_prefix}/username"
  type      = "SecureString"
  value     = var.db_username
  overwrite = true
}

resource "aws_ssm_parameter" "password" {
  name      = "${local.ssm_prefix}/password"
  type      = "SecureString"
  value     = random_password.db.result
  overwrite = true
}

# Utilisés par le module ecs (qui ne reçoit que des ARN SSM)
resource "aws_ssm_parameter" "host" {
  name      = "${local.ssm_prefix}/host"
  type      = "SecureString"
  value     = aws_db_instance.main.address
  overwrite = true
}

resource "aws_ssm_parameter" "port" {
  name      = "${local.ssm_prefix}/port"
  type      = "SecureString"
  value     = tostring(aws_db_instance.main.port)
  overwrite = true
}

resource "aws_ssm_parameter" "name" {
  name      = "${local.ssm_prefix}/name"
  type      = "SecureString"
  value     = var.db_name
  overwrite = true
}