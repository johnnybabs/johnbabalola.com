output "budget_sns_topic_arn" {
  description = "SNS topic ARN for budget alerts. Confirm the email subscription AWS sends to baabalola@gmail.com."
  value       = module.budgets.sns_topic_arn
}

output "name_servers" {
  description = "Route 53 NS records to set at the domain registrar."
  value       = module.dns.name_servers
}

output "zone_id" {
  description = "Route 53 hosted zone ID. Used by certificate and site modules."
  value       = module.dns.zone_id
}

output "certificate_arn" {
  description = "Validated ACM certificate ARN (us-east-1) for the CloudFront distribution."
  value       = module.certificate.certificate_arn
}

# Further outputs added as modules are wired in (Tasks 7, 8).
