terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.36.0"
      configuration_aliases = [aws.us-east-1, aws]
    }
  }
}

locals {
  domain_name = lower(var.domain_name)
  www_domain_name = "www.${local.domain_name}"
  bucket_name = local.domain_name
  www_bucket_name = local.www_domain_name
  origin_access = lower(var.s3_access_method)
}

data "aws_caller_identity" "current" {}

