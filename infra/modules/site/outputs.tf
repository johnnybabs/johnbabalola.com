output "bucket_id" {
  description = "Name of the origin S3 bucket (for s3 sync in the deploy pipeline)."
  value       = aws_s3_bucket.site.id
}

output "bucket_arn" {
  description = "ARN of the origin S3 bucket (for the github-oidc deploy policy)."
  value       = aws_s3_bucket.site.arn
}

output "distribution_id" {
  description = "CloudFront distribution ID (for cache invalidation in the pipeline)."
  value       = aws_cloudfront_distribution.site.id
}

output "distribution_arn" {
  description = "CloudFront distribution ARN (for the github-oidc invalidation policy)."
  value       = aws_cloudfront_distribution.site.arn
}

output "distribution_domain_name" {
  description = "CloudFront domain name, target for the Route 53 alias records."
  value       = aws_cloudfront_distribution.site.domain_name
}

output "distribution_hosted_zone_id" {
  description = "CloudFront hosted zone ID, for the Route 53 alias records."
  value       = aws_cloudfront_distribution.site.hosted_zone_id
}
