# modules/alb/main.tf

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "alb_security_group_id" {
  type = string
}

variable "access_logs_bucket" {
  type = string
}

# true while httpd:alpine placeholder images are used
variable "use_placeholder_images" {
  type    = bool
  default = true
}

resource "aws_lb" "this" {
  name               = "fixmycity-alb"
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids

  access_logs {
    bucket  = var.access_logs_bucket
    prefix  = "alb"
    enabled = true
  }
}

resource "aws_lb_target_group" "frontend" {
  name                 = "fixmycity-frontend-tg"
  target_type          = "instance"
  protocol             = "HTTP"
  port                 = 3000
  vpc_id               = var.vpc_id
  deregistration_delay = 30

  health_check {
    port    = "traffic-port"
    path    = "/"
    matcher = var.use_placeholder_images ? "200-499" : "200-399"
  }
}

resource "aws_lb_target_group" "backend" {
  name                 = "fixmycity-backend-tg"
  target_type          = "instance"
  protocol             = "HTTP"
  port                 = 4000
  vpc_id               = var.vpc_id
  deregistration_delay = 30

  health_check {
    port    = "traffic-port"
    path    = var.use_placeholder_images ? "/" : "/api/v1/health"
    matcher = var.use_placeholder_images ? "200-499" : "200"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

resource "aws_lb_listener_rule" "api" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}
