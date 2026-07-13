terraform {
  backend "s3" {
    bucket         = "johnnybabs-tf-state"
    key            = "johnbabalola.com/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "johnnybabs-terraform-locks"
    encrypt        = true
  }
}
