variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "bucket_suffix" {
  description = "Suffixe optionnel contre les collisions de noms S3"
  type        = string
  default     = ""
}

variable "cors_allowed_origins" {
  description = "Origines autorisées pour PUT/GET (DNS de l'ALB, etc.)"
  type        = list(string)
  default     = ["*"]
}

variable "media_public_read" {
  type    = bool
  default = false
}

variable "media_path_pattern" {
  type    = string
  default = "/media/*"
}