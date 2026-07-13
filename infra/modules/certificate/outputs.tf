output "certificate_arn" {
  description = "ARN of the validated ACM certificate, for the CloudFront distribution (site module)."
  # Reference the validation resource so consumers wait for ISSUED, not just creation.
  value = aws_acm_certificate_validation.this.certificate_arn
}
