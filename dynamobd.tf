terraform {
  backend "s3" {
    bucket         = "my-bucket-saad"
    key            = "terraform.tfstate"
    region         = "eu-central-1"
    encrypt        = true
  }
}

# resource "aws_dynamodb_table" "dynamodb" {
#   name         = "existing-dynamodb"
#   billing_mode = "PAY_PER_REQUEST"
#   hash_key     = "LockID"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }