output "sns_topic_arn" {
  description = "ARN of the SNS topic that receives budget alert notifications."
  value       = aws_sns_topic.budget_alerts.arn
}

output "budget_name" {
  description = "Name of the AWS Budgets budget resource."
  value       = aws_budgets_budget.monthly.name
}
