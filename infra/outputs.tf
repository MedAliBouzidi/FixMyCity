output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public Subnet IDs (/27)"
  value       = module.vpc.public_subnet_ids
}

output "private_backend_subnet_ids" {
  description = "Private Backend App Subnet IDs (/27)"
  value       = module.vpc.private_backend_subnet_ids
}

output "private_db_subnet_ids" {
  description = "Private DB Subnet IDs (/27)"
  value       = module.vpc.private_db_subnet_ids
}

output "frontend_instance_id" {
  description = "L3 Frontend EC2 Instance ID (in Public Subnet 1)"
  value       = module.compute.frontend_instance_id
}

output "backend_instance_id" {
  description = "L3 Backend EC2 Instance ID (in Private Backend Subnet 1)"
  value       = module.compute.backend_instance_id
}

output "backend_instance_private_ip" {
  description = "L3 Backend EC2 Private IP"
  value       = module.compute.backend_instance_private_ip
}
