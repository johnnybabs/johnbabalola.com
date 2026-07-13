output "budget_sns_topic_arn" {
  description = "SNS topic ARN for budget alerts. Confirm the email subscription AWS sends to baabalola@gmail.com."
  value       = module.budgets.sns_topic_arn
}

# Further outputs added as modules are wired in (Tasks 4-8).
