variable "region" {
  description = "AWS region for the state bucket and lock table."
  type        = string
  default     = "eu-west-2"
}

variable "state_bucket" {
  description = "Name of the shared S3 bucket that stores Terraform state for all portfolio projects."
  type        = string
  default     = "johnnybabs-tf-state"
}

variable "lock_table" {
  description = "Name of the DynamoDB table used for Terraform state locking across all portfolio projects."
  type        = string
  default     = "johnnybabs-terraform-locks"
}
