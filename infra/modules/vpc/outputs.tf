output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}

output "private_backend_subnet_ids" {
  value = [aws_subnet.private_backend_1.id, aws_subnet.private_backend_2.id]
}

output "private_db_subnet_ids" {
  value = [aws_subnet.private_db_1.id, aws_subnet.private_db_2.id]
}

output "nat_gateway_id" {
  value = aws_nat_gateway.nat_gw.id
}
