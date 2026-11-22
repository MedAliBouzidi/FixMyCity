output "db_instance_id" {
  value = aws_db_instance.main.identifier
}

output "db_endpoint" {
  value = aws_db_instance.main.endpoint
}

output "db_address" {
  value = aws_db_instance.main.address
}

output "ssm_parameter_arns" {
  value = {
    username = aws_ssm_parameter.username.arn
    password = aws_ssm_parameter.password.arn
    host     = aws_ssm_parameter.host.arn
    port     = aws_ssm_parameter.port.arn
    name     = aws_ssm_parameter.name.arn
  }
}