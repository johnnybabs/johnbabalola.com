# Bootstrap: creates the shared state bucket and lock table.
#
# HOW TO USE:
#   cd infra/bootstrap
#   terraform init          (local state only — no backend block)
#   terraform plan
#   terraform apply
#
# After apply: verify the bucket exists, then proceed to infra/ and run
# `terraform init` to migrate the main config to the remote backend.
# The local terraform.tfstate in this directory can be discarded once the
# bucket is confirmed; re-run from scratch if the bucket ever needs recreating.

data "aws_caller_identity" "current" {}

# --------------------------------------------------------------------------
# Access-logs bucket (CKV_AWS_18 fix: target for state bucket server access logs)
# --------------------------------------------------------------------------

resource "aws_s3_bucket" "state_logs" {
  #checkov:skip=CKV_AWS_18:Access-log buckets do not log their own access (recursive); CloudTrail provides the audit trail for this bucket. See EXC-010.
  #checkov:skip=CKV_AWS_144:Log archive does not require cross-region replication at lab scale; Tier 3 per DevSecOps standard. See EXC-009.
  #checkov:skip=CKV_AWS_145:AWS-managed SSE is the Tier 2 lab baseline; CMK demonstrated in Project C per DevSecOps standard. See EXC-008.
  #checkov:skip=CKV2_AWS_62:Log archive bucket does not require event notifications; Tier 3 per DevSecOps standard. See EXC-010.
  bucket = "${var.state_bucket}-logs"
}

resource "aws_s3_bucket_public_access_block" "state_logs" {
  bucket = aws_s3_bucket.state_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state_logs" {
  bucket = aws_s3_bucket.state_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Grants the S3 log-delivery service permission to write; scoped to this account.
resource "aws_s3_bucket_policy" "state_logs" {
  bucket     = aws_s3_bucket.state_logs.id
  depends_on = [aws_s3_bucket_public_access_block.state_logs]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowS3LogDelivery"
        Effect = "Allow"
        Principal = {
          Service = "logging.s3.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.state_logs.arn}/logs/*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

# --------------------------------------------------------------------------
# State bucket
# --------------------------------------------------------------------------

resource "aws_s3_bucket" "state" {
  #checkov:skip=CKV_AWS_144:Terraform state does not require cross-region replication at lab scale; Tier 3 per DevSecOps standard. See EXC-009.
  #checkov:skip=CKV_AWS_145:AWS-managed SSE (AES256) is the Tier 2 lab baseline; CMK demonstrated in Project C per DevSecOps standard. See EXC-008.
  #checkov:skip=CKV2_AWS_62:State bucket event notifications out of scope for portfolio; CloudTrail provides the audit trail; Tier 3. See EXC-010.
  bucket = var.state_bucket

  lifecycle {
    prevent_destroy = true
  }
}

# CKV_AWS_18 fix: enable server access logging to the dedicated logs bucket.
resource "aws_s3_bucket_logging" "state" {
  bucket        = aws_s3_bucket.state.id
  target_bucket = aws_s3_bucket.state_logs.id
  target_prefix = "logs/"
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket = aws_s3_bucket.state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    id     = "state-retention"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    # CKV_AWS_300 fix: abort orphaned multipart uploads after 7 days.
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# --------------------------------------------------------------------------
# DynamoDB lock table
# --------------------------------------------------------------------------

resource "aws_dynamodb_table" "lock" {
  #checkov:skip=CKV_AWS_119:AWS-managed SSE is the Tier 2 lab baseline; CMK demonstrated in Project C per DevSecOps standard. See EXC-007.
  name         = var.lock_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }
}
