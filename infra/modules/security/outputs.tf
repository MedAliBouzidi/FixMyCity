output "sg_alb_id" {
  value = aws_security_group.sg_alb.id
}

output "sg_app_frontend_id" {
  value = aws_security_group.sg_app_frontend.id
}

output "sg_app_backend_id" {
  value = aws_security_group.sg_app_backend.id
}

output "sg_rds_id" {
  value = aws_security_group.sg_rds.id
}