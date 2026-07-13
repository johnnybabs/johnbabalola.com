variable "domain_name" {
  description = "Apex domain for the certificate. The wildcard SAN is derived as *.<domain_name>."
  type        = string
}

variable "zone_id" {
  description = "Route 53 hosted zone ID where DNS validation records are created."
  type        = string
}
