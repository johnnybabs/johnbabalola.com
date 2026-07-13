variable "region" {
  description = "Primary AWS region for all resources except the ACM certificate."
  type        = string
  default     = "eu-west-2"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.region))
    error_message = "Must be a valid AWS region identifier, e.g. eu-west-2."
  }
}

variable "domain_name" {
  description = "Apex domain, e.g. johnbabalola.com. The www subdomain and wildcard cert SAN are derived from this."
  type        = string
  default     = "johnbabalola.com"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]+\\.[a-z]{2,}$", var.domain_name))
    error_message = "Must be a valid fully-qualified domain name."
  }
}

variable "alert_email" {
  description = "Email address for AWS Budgets and SNS alert notifications."
  type        = string
  default     = "baabalola@gmail.com"
}
