terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
      # CloudFront only accepts ACM certificates from us-east-1, so the
      # certificate and its validation must use the us_east_1 aliased provider.
      # The default (eu-west-2) provider creates the Route 53 validation records
      # (Route 53 is a global service).
      configuration_aliases = [aws.us_east_1]
    }
  }
}
