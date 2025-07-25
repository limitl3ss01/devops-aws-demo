provider "aws" {
  region = "eu-central-1"
}

resource "aws_s3_bucket" "tf_state" {
  bucket = "devops-aws-demo-tfstate-limitl3ss01"
  force_destroy = true
  versioning {
    enabled = true
  }
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_dynamodb_table" "tf_lock" {
  name         = "devops-aws-demo-tf-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

output "s3_bucket" {
  value = aws_s3_bucket.tf_state.bucket
}

output "dynamodb_table" {
  value = aws_dynamodb_table.tf_lock.name
} 