# Private origin bucket. No public access, no website endpoint — CloudFront
# reaches it only through Origin Access Control (see cloudfront.tf).
resource "aws_s3_bucket" "site" {
  #checkov:skip=CKV_AWS_144:Static site content is rebuilt from the git repo on every deploy; cross-region replication adds cost with no recovery value. Tier 3. See EXC-009.
  #checkov:skip=CKV_AWS_145:AWS-managed SSE (AES256) is the Tier 2 lab baseline; CMK demonstrated in Project C. Content is public static HTML with no secrets. See EXC-008.
  #checkov:skip=CKV2_AWS_62:Event notifications duplicate CloudTrail coverage for a static site; deploys are attributable via GitHub Actions logs. Tier 3. See EXC-010.
  #checkov:skip=CKV_AWS_18:Origin bucket is reached only via CloudFront OAC, so there is no direct S3 access to log; CloudFront access logging is a v1 backlog item (PRD section 3). See EXC-014.
  bucket = var.bucket_name
}

resource "aws_s3_bucket_public_access_block" "site" {
  bucket = aws_s3_bucket.site.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "site" {
  bucket = aws_s3_bucket.site.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "site" {
  bucket = aws_s3_bucket.site.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "site" {
  bucket = aws_s3_bucket.site.id

  rule {
    id     = "site-retention"
    status = "Enabled"

    filter {}

    # Keep a short rollback window of superseded objects without unbounded growth.
    noncurrent_version_expiration {
      noncurrent_days = 30
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# Allow only this distribution's OAC to read objects. Scoped by SourceArn to the
# distribution, so no other principal (or distribution) can read the bucket.
resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.site.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontOACRead"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.site.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.site.arn
          }
        }
      }
    ]
  })
}
