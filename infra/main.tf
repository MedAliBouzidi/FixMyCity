# 1. Networking Module (VPC, Subnets across 2 AZs, IGW, NAT GW, S3 Gateway Endpoint)
module "networking" {
  source = "modules/networking"

  project_name = var.project_name
  environment  = var.environment
}

# 2. Security Module (Chained Security Groups for ALB, Frontend, Backend, Database)
module "security" {
  source = "modules/security"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.networking.vpc_id
}

# 3. Storage Module (S3 Media & Archives buckets via CloudFormation, CORS, Policies, Lifecycle)
module "storage" {
  source = "modules/storage"

  project_name         = var.project_name
  environment          = var.environment
  bucket_suffix        = var.bucket_suffix
  cors_allowed_origins = var.cors_allowed_origins
  media_public_read    = var.media_public_read
  media_path_pattern   = "/media/*"
}

# 4. Database Module (RDS MySQL 8.0 Single-AZ, DB Subnet Group, SSM Parameters with overwrite)
module "database" {
  source = "modules/database"

  project_name               = var.project_name
  environment                = var.environment
  db_subnet_ids              = module.networking.db_subnet_ids
  database_security_group_id = module.security.database_security_group_id
  db_instance_class          = var.db_instance_class
}

# 5. ECR Module (Frontend and Backend Mutable Container Registries)
module "ecr" {
  source = "modules/ecr"

  project_name = var.project_name
  environment  = var.environment
}

# 6. ALB Module (Internet-facing ALB, Target Groups 3000 & 4000, Path-based Routing, Access Logging)
module "alb" {
  source = "modules/alb"

  project_name                      = var.project_name
  environment                       = var.environment
  vpc_id                            = module.networking.vpc_id
  public_subnet_ids                 = module.networking.public_subnet_ids
  alb_security_group_id             = module.security.alb_security_group_id
  archives_bucket_name              = module.storage.archives_bucket_name
  archives_bucket_policy_dependency = module.storage.archives_bucket_policy_dependency
  frontend_health_check_path        = var.frontend_health_check_path
  backend_health_check_path         = var.backend_health_check_path
}

# 7. CDN Module (CloudFront fronting ALB and S3 Media with hardcoded managed policy IDs)
module "cdn" {
  source = "modules/cdn"

  project_name                      = var.project_name
  environment                       = var.environment
  enable_cdn                        = var.enable_cdn
  alb_dns_name                      = module.alb.alb_dns_name
  media_bucket_regional_domain_name = module.storage.media_bucket_regional_domain_name
  media_path_pattern                = "/media/*"
  media_access_mode                 = var.media_access_mode
}

# 8. Monitoring Module (CloudWatch Log Groups, SNS Topics, Alarms for RDS, ALB 5xx, Unhealthy Hosts)
module "monitoring" {
  source = "modules/monitoring"

  project_name                     = var.project_name
  environment                      = var.environment
  alert_email                      = var.alert_email
  db_instance_id                   = module.database.db_instance_id
  alb_arn_suffix                   = module.alb.alb_arn_suffix
  frontend_target_group_arn_suffix = module.alb.frontend_target_group_arn_suffix
  backend_target_group_arn_suffix  = module.alb.backend_target_group_arn_suffix
}

# 9. ECS Module (ECS Cluster, EC2 ASG across Private Subnets, Task Definitions with SSM Secrets, Services)
module "ecs" {
  source = "modules/ecs"

  project_name                 = var.project_name
  environment                  = var.environment
  aws_region                   = var.aws_region
  app_subnet_ids               = module.networking.app_subnet_ids
  frontend_security_group_id   = module.security.frontend_security_group_id
  backend_security_group_id    = module.security.backend_security_group_id
  frontend_target_group_arn    = module.alb.frontend_target_group_arn
  backend_target_group_arn     = module.alb.backend_target_group_arn
  frontend_image               = var.frontend_image
  backend_image                = var.backend_image
  db_ssm_parameter_arns        = module.database.ssm_parameter_arns
  frontend_log_group_name      = module.monitoring.frontend_log_group_name
  backend_log_group_name       = module.monitoring.backend_log_group_name
  alb_dns_name                 = module.alb.alb_dns_name
  media_bucket_name            = module.storage.media_bucket_name
  app_events_topic_arn         = module.monitoring.app_events_topic_arn
  alb_listener_rule_dependency = module.alb.backend_listener_rule_arn
}

