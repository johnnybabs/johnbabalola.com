# Apex and www alias records pointing at CloudFront. Both A (IPv4) and AAAA
# (IPv6) since the distribution has is_ipv6_enabled. www is redirected to the
# apex by the CloudFront function, but still needs a record to reach the edge.
locals {
  alias_records = {
    "apex-a"    = { name = var.domain_name, type = "A" }
    "apex-aaaa" = { name = var.domain_name, type = "AAAA" }
    "www-a"     = { name = "www.${var.domain_name}", type = "A" }
    "www-aaaa"  = { name = "www.${var.domain_name}", type = "AAAA" }
  }
}

resource "aws_route53_record" "alias" {
  for_each = local.alias_records

  zone_id = var.zone_id
  name    = each.value.name
  type    = each.value.type

  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}
