terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Backend is configured in backend.tf, added in Task 3 (bootstrap).
  # During scaffold, validate with: terraform init -backend=false
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project  = "website"
      Owner    = "johnnybabs"
      Teardown = "false"
    }
  }
}

# Second provider alias for us-east-1: required for ACM certificates
# used by CloudFront (CloudFront only accepts certs from us-east-1).
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  default_tags {
    tags = {
      Project  = "website"
      Owner    = "johnnybabs"
      Teardown = "false"
    }
  }
}
