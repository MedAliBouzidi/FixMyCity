terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "FixMyCity"
      Env       = "Dev"
      Group     = var.group_prefix
      ManagedBy = "Terraform"
    }
  }
}

module "vpc" {
  source       = "./modules/vpc"
  aws_region   = var.aws_region
  group_prefix = var.group_prefix
  vpc_cidr     = var.vpc_cidr
}

module "security" {
  source       = "./modules/security"
  group_prefix = var.group_prefix
  vpc_id       = module.vpc.vpc_id
}

module "compute" {
  source                = "./modules/compute"
  aws_region            = var.aws_region
  group_prefix          = var.group_prefix
  public_subnet_1_id    = module.vpc.public_subnet_ids[0]
  private_backend_1_id  = module.vpc.private_backend_subnet_ids[0]
  sg_app_frontend_id    = module.security.sg_app_frontend_id
  sg_app_backend_id     = module.security.sg_app_backend_id
  nat_gateway_id        = module.vpc.nat_gateway_id
}
