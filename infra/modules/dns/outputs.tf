output "zone_id" {
  description = "Route 53 hosted zone ID. Consumed by the certificate and site modules for record creation."
  value       = aws_route53_zone.main.zone_id
}

output "name_servers" {
  description = "The four NS records to set at the domain registrar."
  value       = aws_route53_zone.main.name_servers
}

output "zone_name" {
  description = "The domain name this zone serves."
  value       = aws_route53_zone.main.name
}

output "query_log_group_arn" {
  description = "CloudWatch log group ARN for Route 53 query logs (us-east-1)."
  value       = aws_cloudwatch_log_group.route53_query.arn
}
