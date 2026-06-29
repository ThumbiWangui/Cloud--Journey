terraform {
  required_version = ">= 1.4.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

locals {
  new_region = "me-central-1"
}

provider "aws" {
  region  = local.new_region
  profile = "default"

  shared_credentials_files = ["C:/Users/user/.aws/credentials"]
  shared_config_files      = ["C:/Users/user/.aws/config"]
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "uae_website_bucket" {
  bucket = "thumbiportfolio1-uae-${random_id.suffix.hex}"

  tags = {
    Name        = "thumbiportfolio1-uae"
    Environment = "Learning"
    Region      = "Middle East UAE"
  }
}

resource "aws_s3_bucket_public_access_block" "uae_website_public_access" {
  bucket = aws_s3_bucket.uae_website_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "uae_website" {
  bucket = aws_s3_bucket.uae_website_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.uae_website_bucket.id

  depends_on = [
    aws_s3_bucket_public_access_block.uae_website_public_access
  ]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadForWebsite"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.uae_website_bucket.arn}/*"
      }
    ]
  })
}

output "new_uae_bucket_name" {
  value = aws_s3_bucket.uae_website_bucket.bucket
}

output "new_uae_website_url" {
  value = "http://${aws_s3_bucket_website_configuration.uae_website.website_endpoint}"
}