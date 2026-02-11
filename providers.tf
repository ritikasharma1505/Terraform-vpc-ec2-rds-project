provider "aws" {
  region     = "us-east-2"       # change as needed
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.28.0"
    }
  }
}

