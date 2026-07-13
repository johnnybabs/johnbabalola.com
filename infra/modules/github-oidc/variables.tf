variable "github_repo" {
  description = "GitHub repository allowed to assume the deploy role, as owner/name."
  type        = string
  default     = "johnnybabs/johnbabalola.com"
}

variable "github_branch" {
  description = "Branch whose workflow runs may assume the role. Trust is pinned to this ref."
  type        = string
  default     = "main"
}

variable "bucket_arn" {
  description = "ARN of the site S3 bucket the deploy role may write to."
  type        = string
}

variable "distribution_arn" {
  description = "ARN of the CloudFront distribution the deploy role may invalidate."
  type        = string
}

variable "role_name" {
  description = "Name of the IAM role assumed by GitHub Actions via OIDC."
  type        = string
  default     = "johnbabalola-com-github-deploy"
}
