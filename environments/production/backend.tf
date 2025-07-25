terraform {
  backend "s3" {
    bucket         = "devops-aws-demo-tfstate-limitl3ss01"
    key            = "production/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "devops-aws-demo-tf-lock"
    encrypt        = true
  }
} 