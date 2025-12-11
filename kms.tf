resource "aws_kms_key" "this" {
  description = "Key to encrypt the Terraform state"
}

resource "aws_kms_alias" "this" {
  target_key_id = aws_kms_key.this.key_id
  name          = var.kms_key_alias
}
