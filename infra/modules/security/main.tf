# 1. sg_alb | Ingress: 80/443 from 0.0.0.0/0
resource "aws_security_group" "sg_alb" {
  name        = "${var.group_prefix}-sg-alb"
  description = "Ingress 80/443 from 0.0.0.0/0"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from Internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.group_prefix}-sg-alb" }
}

# 2. sg_app_frontend | Ingress: 3000 from sg_alb
resource "aws_security_group" "sg_app_frontend" {
  name        = "${var.group_prefix}-sg-app-frontend"
  description = "Ingress 3000 strictly from sg_alb"
  vpc_id      = var.vpc_id

  ingress {
    description     = "NextJS Port 3000 from ALB"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.group_prefix}-sg-app-frontend" }
}

# 3. sg_app_backend | Ingress: 4000 from sg_app_frontend
resource "aws_security_group" "sg_app_backend" {
  name        = "${var.group_prefix}-sg-app-backend"
  description = "Ingress 4000 strictly from sg_app_frontend"
  vpc_id      = var.vpc_id

  ingress {
    description     = "NestJS Port 4000 from Frontend SG"
    from_port       = 4000
    to_port         = 4000
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_app_frontend.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.group_prefix}-sg-app-backend" }
}

# 4. sg_rds | Ingress: 3306 from sg_app_backend
resource "aws_security_group" "sg_rds" {
  name        = "${var.group_prefix}-sg-rds"
  description = "Ingress 3306 strictly from sg_app_backend"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL Port 3306 from Backend SG"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_app_backend.id]
  }

  tags = { Name = "${var.group_prefix}-sg-rds" }
}