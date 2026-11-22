variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "db_subnet_ids" {
  description = "2 sous-réseaux DB privés (1 par AZ)"
  type        = list(string)

  validation {
    condition     = length(var.db_subnet_ids) >= 2
    error_message = "Le DB Subnet Group exige au moins 2 sous-réseaux (2 AZ)."
  }
}

variable "database_security_group_id" {
  description = "ID de sg-database"
  type        = string
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_name" {
  type    = string
  default = "fixmycity"
}

variable "db_username" {
  type    = string
  default = "admin"
}