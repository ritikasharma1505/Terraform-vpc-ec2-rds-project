# Remote State Locking (S3 + DynamoDB)
terraform {

  backend "s3" {
    bucket         = "terraform-state-bucket-120226"
    key            = "dev/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

