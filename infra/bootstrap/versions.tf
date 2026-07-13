terraform {
  # No backend block — bootstrap state is intentionally local.
  # See docs/decisions.md: "Terraform state bootstrap uses local state by design"
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
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
