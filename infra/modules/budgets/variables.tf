variable "name_prefix" {
  description = "Prefix for SNS topic and budget resource names."
  type        = string
  default     = "johnnybabs"
}

variable "limit_usd" {
  description = "Monthly budget limit in USD. AWS Budgets is USD-only. See docs/decisions.md for GBP conversion note."
  type        = string
  default     = "63"

  validation {
    condition     = can(tonumber(var.limit_usd)) && tonumber(var.limit_usd) > 0
    error_message = "limit_usd must be a positive number as a string, e.g. \"63\"."
  }
}

variable "alert_email" {
  description = "Email address to receive budget alert notifications via SNS subscription."
  type        = string
}
