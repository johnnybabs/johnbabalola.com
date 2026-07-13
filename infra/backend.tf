terraform {
  backend "s3" {
    bucket       = "johnnybabs-tf-state"
    key          = "johnbabalola.com/terraform.tfstate"
    region       = "eu-west-2"
    encrypt      = true
    use_lockfile = true  # S3-native locking (Terraform >= 1.10); replaces dynamodb_table
  }
}
