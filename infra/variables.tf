variable "aws_region" {
  description = "Imposed AWS region (§3.1)"
  type        = string
  default     = "us-east-1"
}

variable "group_prefix" {
  description = "Group naming prefix (§3.1)"
  type        = string
  default     = "grp1-fixmycity"
}

variable "vpc_cidr" {
  description = "VPC CIDR (/16 required to encompass 10.0.1.0/27 through 10.0.21.0/27)"
  type        = string
  default     = "10.0.0.0/16"
}
