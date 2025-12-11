variable "aws_account_id" {
  type        = string
  description = "AWS account ID of the target account."
}

variable "region" {
  type        = string
  description = "AWS region for all resources."
}

variable "oidc_repo" {
  type        = string
  description = "GitHub OIDC subject pattern, e.g. 'org/repo:*'."
}

variable "enable_dynamodb_locking" {
  type        = bool
  description = "Whether to create a DynamoDB table for Terraform state locking."
  default     = false
}

variable "state_bucket_name" {
  type        = string
  description = "Optional custom name for the Terraform state bucket. If empty, a name is derived from the account ID."
  default     = ""
}

variable "kms_key_alias" {
  type        = string
  description = "Alias for the KMS key used to encrypt Terraform state."
  default     = "alias/tfstate"
}

variable "enable_github_oidc" {
  type        = bool
  description = "Whether to create the GitHub OIDC provider and related IAM trust policy."
  default     = true
}


variable "enable_datadog_permissions" {
  type        = bool
  description = "Whether to grant additional permissions for Datadog / Opsgenie integration."
  default     = false
}

variable "opsgenie_secret_name" {
  type        = string
  description = "Name of the Opsgenie API key secret (used only if enable_datadog_permissions is true)."
  default     = "opsgenie/api_key"
}

variable "datadog_keys_secret_name" {
  type        = string
  description = "Name of the Datadog keys secret (used only if enable_datadog_permissions is true)."
  default     = "datadog/keys"
}

variable "datadog_integration_policy_name" {
  type        = string
  description = "Name of the Datadog integration IAM policy (used only if enable_datadog_permissions is true)."
  default     = "DatadogIntegrationPolicy"
}

variable "datadog_integration_role_name" {
  type        = string
  description = "Name of the Datadog integration IAM role (used only if enable_datadog_permissions is true)."
  default     = "DatadogIntegrationRole"
}
