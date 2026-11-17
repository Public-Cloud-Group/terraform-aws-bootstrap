resource "aws_kms_key" "this" {
  description         = "Key to encrypt the Terraform state"
  enable_key_rotation = var.enable_kms_key_rotation
}

resource "aws_kms_alias" "this" {
  target_key_id = aws_kms_key.this.key_id
  name          = var.kms_key_alias
}
