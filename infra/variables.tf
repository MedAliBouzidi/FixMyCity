variable "project_name" {
  description = "The project name prefix"
  type        = string
  default     = "fixmycity"
}

variable "environment" {
  description = "The deployment environment"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region for the Learner Lab deployment (restricted to us-east-1 and us-west-2)"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  type    = string
  default = "default"
}

variable "db_instance_class" {
  description = "RDS DB instance class (Learner Lab limit: micro to large)"
  type        = string
  default     = "db.t3.micro"
}

variable "bucket_suffix" {
  description = "Optional suffix to prevent global S3 bucket name collisions in AWS Learner Lab"
  type        = string
  default     = ""
}

variable "cors_allowed_origins" {
  description = "Allowed CORS origins for the media bucket"
  type        = list(string)
  default     = ["*"]
}

variable "alert_email" {
  description = "Email address for operations alerts and SNS notifications (no default, required)"
  type        = string
  default     = "teamdev908@gmail.com"
}

variable "enable_cdn" {
  description = "Whether to deploy the CloudFront CDN distribution (Learner Lab accounts do not have cloudfront:CreateDistribution permissions and must set this to false)"
  type        = bool
  default     = false
}

variable "media_access_mode" {
  description = "CloudFront S3 origin access mode: 'public' (Learner Lab compatible), 'oac', or 'oai'"
  type        = string
  default     = "public"

  validation {
    condition     = contains(["public", "oac", "oai"], var.media_access_mode)
    error_message = "media_access_mode must be one of: 'public', 'oac', 'oai'."
  }
}

variable "media_public_read" {
  description = "Enables public read bucket policy on media prefix for CloudFront public access mode"
  type        = bool
  default     = true
}

variable "frontend_image" {
  description = "Container image for frontend service"
  type        = string
  default     = "httpd:alpine"
}

variable "backend_image" {
  description = "Container image for backend service"
  type        = string
  default     = "httpd:alpine"
}

variable "frontend_health_check_path" {
  description = "Health check path for frontend ALB target group"
  type        = string
  default     = "/"
}

variable "backend_health_check_path" {
  description = "Health check path for backend ALB target group"
  type        = string
  default     = "/api/v1/health"
}
