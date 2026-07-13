# ACM certificate for the apex plus a wildcard SAN, so future subdomain demos
# (vidcast.johnbabalola.com etc.) reuse this one cert. Must live in us-east-1
# for CloudFront. See docs/adr/0002-cert-scope.md.
resource "aws_acm_certificate" "this" {
  provider = aws.us_east_1

  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# One validation record per domain/SAN. Keyed by domain_name (statically known
# from the cert config) rather than the computed record name, so for_each keys
# resolve at plan time. The apex and wildcard yield an identical validation
# record; allow_overwrite makes the duplicate UPSERT idempotent.
resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id         = var.zone_id
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
  ttl             = 60
  allow_overwrite = true
}

# Blocks until ACM observes the DNS records and moves the certificate to ISSUED.
resource "aws_acm_certificate_validation" "this" {
  provider = aws.us_east_1

  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}
