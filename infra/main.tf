# Task 3: backend bootstrap (see infra/bootstrap/ — run that first)

# Task 6: account-wide cost budget — apply before any resource that costs money
module "budgets" {
  source      = "./modules/budgets"
  alert_email = var.alert_email

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
}

# Task 4: dns module
module "dns" {
  source      = "./modules/dns"
  domain_name = var.domain_name

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
}

# Task 5: certificate module — ACM in us-east-1, DNS-validated via the dns zone
module "certificate" {
  source      = "./modules/certificate"
  domain_name = var.domain_name
  zone_id     = module.dns.zone_id

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
}

# Task 7: site module — S3 (private, OAC) + CloudFront + security headers + alias records
module "site" {
  source          = "./modules/site"
  domain_name     = var.domain_name
  zone_id         = module.dns.zone_id
  certificate_arn = module.certificate.certificate_arn
}

# Task 8: github-oidc module
