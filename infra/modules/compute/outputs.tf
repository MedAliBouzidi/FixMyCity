output "frontend_instance_id" {
  value = aws_instance.frontend_node.id
}

output "backend_instance_id" {
  value = aws_instance.backend_node.id
}

output "backend_instance_private_ip" {
  value = aws_instance.backend_node.private_ip
}