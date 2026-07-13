output "role_arn" {
  description = "ARN of the deploy role for the GitHub Actions workflow (role-to-assume)."
  value       = aws_iam_role.deploy.arn
}

output "oidc_provider_arn" {
  description = "ARN of the GitHub Actions OIDC provider."
  value       = aws_iam_openid_connect_provider.github.arn
}
