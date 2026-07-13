terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
      # us_east_1 alias required: AWS Budgets SNS notifications must use
      # an SNS topic in us-east-1 regardless of the account's primary region.
      configuration_aliases = [aws.us_east_1]
    }
  }
}
