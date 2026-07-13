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

# Further outputs added as modules are wired in (Tasks 5, 7, 8).
