resource "aws_route53_zone" "main" {
  #checkov:skip=CKV2_AWS_38:No A records exist yet; added in the site module (Task 7) once CloudFront is provisioned.
  name = var.domain_name
}
