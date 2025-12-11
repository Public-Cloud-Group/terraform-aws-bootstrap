resource "aws_dynamodb_table" "terraform" {
  count = var.enable_dynamodb_locking ? 1 : 0

  name         = "terraform"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "LockID"
    type = "S"
  }
}
