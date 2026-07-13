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
}

# Task 5: certificate module — added after NS propagation confirmed
# Task 7: site module — added after cert reaches ISSUED
# Task 8: github-oidc module
