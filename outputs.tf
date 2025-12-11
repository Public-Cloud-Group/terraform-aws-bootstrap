output "tf_state_bucket_name" {
  description = "Name of the S3 bucket used for Terraform remote state."
  value       = aws_s3_bucket.state.bucket
}

output "tf_state_bucket_arn" {
  description = "ARN of the S3 bucket used for Terraform remote state."
  value       = aws_s3_bucket.state.arn
}

output "tf_kms_key_arn" {
  description = "ARN of the KMS key used to encrypt Terraform state."
  value       = aws_kms_key.this.arn
}

output "tf_dynamodb_table_name" {
  description = "Name of the DynamoDB table used for Terraform state locking, if created."
  value       = try(aws_dynamodb_table.terraform[0].name, null)
}

output "github_actions_role_arn" {
  description = "ARN of the IAM role assumed by GitHub Actions, if created."
  value       = try(aws_iam_role.github_action_role[0].arn, null)
}

output "github_oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider, if created."
  value       = try(aws_iam_openid_connect_provider.github[0].arn, null)
}
