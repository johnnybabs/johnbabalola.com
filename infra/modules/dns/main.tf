data "aws_caller_identity" "current" {}

resource "aws_route53_zone" "main" {
  #checkov:skip=CKV2_AWS_38:DNSSEC requires a DS record at the registrar on top of a newly established NS delegation; a mismatched or premature DS record makes the domain unresolvable for the DS TTL. Deferring until the NS delegation is proven stable is an explicit availability-over-integrity trade-off. See EXC-011; revisit after Sprint 2.
  name = var.domain_name
}

# --------------------------------------------------------------------------
# Route 53 query logging (CKV2_AWS_39)
# Log group must be in us-east-1 — same regional constraint as ACM certs for CloudFront.
# --------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "route53_query" {
  #checkov:skip=CKV_AWS_158:CloudWatch Logs are encrypted at rest with an AWS-owned key by default; a customer-managed CMK is the Tier 2 lab baseline (demonstrated in Project C). DNS query logs contain no secrets. See EXC-012.
  #checkov:skip=CKV_AWS_338:7-day retention is the deliberate lab standard per DevSecOps standards (Project D rule); 1 year of DNS query logs has no value here and adds cost. See EXC-013.
  provider          = aws.us_east_1
  name              = "/aws/route53/${var.domain_name}"
  retention_in_days = 7
}

# Account-level resource policy granting Route 53 permission to write query logs.
resource "aws_cloudwatch_log_resource_policy" "route53_query" {
  provider    = aws.us_east_1
  policy_name = "route53-query-logging-${replace(var.domain_name, ".", "-")}"

  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Route53QueryLogsToCloudWatch"
        Effect = "Allow"
        Principal = {
          Service = "route53.amazonaws.com"
        }
        Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "${aws_cloudwatch_log_group.route53_query.arn}:*"
        Condition = {
          ArnLike = {
            "aws:SourceArn" = "arn:aws:route53:::hostedzone/${aws_route53_zone.main.zone_id}"
          }
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

resource "aws_route53_query_log" "main" {
  zone_id                  = aws_route53_zone.main.zone_id
  cloudwatch_log_group_arn = "${aws_cloudwatch_log_group.route53_query.arn}:*"

  depends_on = [aws_cloudwatch_log_resource_policy.route53_query]
}
