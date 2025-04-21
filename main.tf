############################################################
# Providers & backend
############################################################
terraform {
  required_version = ">= 0.36.4"

  cloud {
    workspaces {
      name = "devsecops"
    }
    organization = "hashira_corp"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# provider "aws" {
#   region = var.aws_region
#   profile = var.aws_profile
# }

############################################################
# Network module (re‑usable)
############################################################
module "network" {
  source = "./modules/network"

  name       = local.name
  cidr_block = var.vpc_cidr
  level      = local.level
}

############################################################
# S3 bucket to hold ZAP reports
############################################################
resource "aws_s3_bucket" "zap_reports" {
  bucket        = "${var.env_name}-zap-reports"
  force_destroy = true

  tags = merge(var.common_tags, {
    "Purpose" = "DAST-reports"
  })
}

############################################################
# ECR repo for the ZAP Lambda container
############################################################
resource "aws_ecr_repository" "zap_lambda" {
  name                 = "zap-lambda"
  image_tag_mutability = "MUTABLE"

  lifecycle {
    prevent_destroy = false
  }

  tags = merge(var.common_tags, {
    "Purpose" = "Container for OWASP ZAP Lambda"
    "Level"   = local.level
  })
}

############################################################
# Lambda function to generate DAST report
############################################################
module "lambda_zap" {
  source = "./modules/lambda_zap"

  bucket_name = aws_s3_bucket.zap_reports.bucket
  bucket_arn  = aws_s3_bucket.zap_reports.arn
  common_tags = var.common_tags
  target_url  = var.target_url
  aws_region  = var.aws_region
}

############################################################
# Github OIDC
############################################################
module "github-oidc" {
  source  = "terraform-module/github-oidc-provider/aws"
  version = "~> 1"

  create_oidc_provider = true
  create_oidc_role     = true

  repositories = ["NwekeChidi/secure-iac"]
  # oidc_role_attach_policies = ["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]
}
