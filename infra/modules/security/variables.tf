variable "project_name" {
  type    = string
  default = "fixmycity"
}

variable "vpc_id" {
  description = "VPC ID from networking module"
  type        = string
}
