output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]
}

output "app_private_subnet_ids" {
  value = [
    aws_subnet.app_a.id,
    aws_subnet.app_b.id
  ]
}

output "db_private_subnet_ids" {
  value = [
    aws_subnet.db_a.id,
    aws_subnet.db_b.id
  ]
}

output "nat_gateway_id" {
  value = aws_nat_gateway.nat.id
}

output "s3_endpoint_id" {
  value = aws_vpc_endpoint.s3.id
}