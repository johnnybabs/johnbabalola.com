output "state_bucket_name" {
  description = "S3 bucket name to use in infra/backend.tf."
  value       = aws_s3_bucket.state.bucket
}

output "lock_table_name" {
  description = "DynamoDB table name to use in infra/backend.tf."
  value       = aws_dynamodb_table.lock.name
}
