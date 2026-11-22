output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name for application and media access"
  value       = module.cdn.cloudfront_domain_name
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = module.alb.alb_dns_name
}

output "ecr_frontend_url" {
  description = "ECR repository URL for the frontend application"
  value       = module.ecr.frontend_repository_url
}

output "ecr_backend_url" {
  description = "ECR repository URL for the backend application"
  value       = module.ecr.backend_repository_url
}

output "media_bucket" {
  description = "Name of the S3 media bucket"
  value       = module.storage.media_bucket_name
}

output "archives_bucket" {
  description = "Name of the S3 archives and logs bucket"
  value       = module.storage.archives_bucket_name
}

output "rds_endpoint" {
  description = "RDS MySQL connection endpoint"
  value       = module.database.db_endpoint
}

output "ssm_prefix" {
  description = "SSM Parameter Store prefix for database connection details"
  value       = module.database.ssm_prefix
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs.ecs_cluster_name
}

output "vpc_id" {
  value = module.networking.vpc_id
}

output "public_subnet_ids" {
  value = module.networking.public_subnet_ids
}

output "app_private_subnet_ids" {
  value = module.networking.app_private_subnet_ids
}

output "db_private_subnet_ids" {
  value = module.networking.db_private_subnet_ids
}

output "alb_sg_id" {
  value = module.security.alb_sg_id
}

output "ecs_instances_sg_id" {
  value = module.security.ecs_instances_sg_id
}

output "database_sg_id" {
  value = module.security.database_sg_id
}