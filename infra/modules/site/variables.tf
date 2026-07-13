variable "domain_name" {
  description = "Apex domain. The distribution serves this and www.<domain_name>."
  type        = string
}

variable "certificate_arn" {
  description = "ARN of the validated ACM certificate in us-east-1 (from the certificate module)."
  type        = string
}

variable "bucket_name" {
  description = "Name of the private S3 origin bucket."
  type        = string
  default     = "johnbabalola-com-site"
}

variable "zone_id" {
  description = "Route 53 hosted zone ID for the apex and www alias records."
  type        = string
}
