terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
      # us_east_1 alias required: Route 53 query log groups must be in us-east-1,
      # matching the constraint on ACM certificates for CloudFront.
      configuration_aliases = [aws.us_east_1]
    }
  }
}
