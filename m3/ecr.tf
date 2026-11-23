# modules/ecr/main.tf

resource "aws_ecr_repository" "frontend" {
  name                 = "fixmycity-frontend"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "backend" {
  name                 = "fixmycity-backend"
  image_tag_mutability = "MUTABLE"
}
