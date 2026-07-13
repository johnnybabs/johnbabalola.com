# SNS topic in us-east-1: AWS Budgets notifications require the topic to be
# in us-east-1 regardless of the account's primary region.
resource "aws_sns_topic" "budget_alerts" {
  provider = aws.us_east_1
  name     = "${var.name_prefix}-budget-alerts"
  # CKV_AWS_26 fix: encrypt topic with the AWS-managed SNS key.
  # Using alias/aws/sns (not a CMK) because Budget publishes to SNS;
  # CMK would require adding budgets.amazonaws.com to the key policy.
  kms_master_key_id = "alias/aws/sns"
}

# Allow AWS Budgets service to publish to this topic.
resource "aws_sns_topic_policy" "budget_alerts" {
  provider = aws.us_east_1
  arn      = aws_sns_topic.budget_alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowBudgetsToPublish"
        Effect = "Allow"
        Principal = {
          Service = "budgets.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.budget_alerts.arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

# Email subscription: John must confirm the email AWS sends before alerts fire.
resource "aws_sns_topic_subscription" "budget_alerts_email" {
  provider  = aws.us_east_1
  topic_arn = aws_sns_topic.budget_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# Account-wide monthly cost budget. This is the cost guardrail for all
# portfolio projects since this is the permanent stack.
resource "aws_budgets_budget" "monthly" {
  name         = "${var.name_prefix}-monthly-cost"
  budget_type  = "COST"
  limit_amount = var.limit_usd
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  # 50% alert: ~£25 spent
  notification {
    comparison_operator       = "GREATER_THAN"
    threshold                 = 50
    threshold_type            = "PERCENTAGE"
    notification_type         = "ACTUAL"
    subscriber_sns_topic_arns = [aws_sns_topic.budget_alerts.arn]
  }

  # 80% alert: ~£40 spent
  notification {
    comparison_operator       = "GREATER_THAN"
    threshold                 = 80
    threshold_type            = "PERCENTAGE"
    notification_type         = "ACTUAL"
    subscriber_sns_topic_arns = [aws_sns_topic.budget_alerts.arn]
  }
}

data "aws_caller_identity" "current" {}
