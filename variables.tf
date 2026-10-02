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
  default     = null
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


variable "enable_gitlab_oidc" {
  type        = bool
  description = "Whether to create the GitLab CI OIDC provider and related IAM trust policy."
  default     = false
}

variable "gitlab_url" {
  type        = string
  description = "GitLab instance URL used as the OIDC issuer. Use https://gitlab.com for SaaS or your self-hosted URL (e.g., https://git.mycompany.com)."
  default     = "https://gitlab.com"
}

variable "gitlab_oidc_project" {
  type        = string
  description = "GitLab CI OIDC subject filter (e.g., 'project_path:mygroup/myrepo:*')."
  default     = null
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

variable "s3_bucket_replication_config" {
  type = object({
    enabled                   = optional(bool, false)
    destination_bucket_name   = optional(string)
    destination_account_id    = optional(string)
    destination_storage_class = optional(string, "STANDARD")
    role_name                 = optional(string, "TerraformStateS3ReplicationRole")
    policy_name               = optional(string, "TerraformStateS3ReplicationPolicy")
    destination_kms_key_arn   = optional(string)
    rtc_enabled               = optional(bool, false)
  })
  description = "Configuration for S3 replication of the state bucket."

  validation {
    condition = !var.s3_bucket_replication_config.enabled || alltrue([
      for v in [
        var.s3_bucket_replication_config.destination_bucket_name,
        var.s3_bucket_replication_config.destination_account_id,
        var.s3_bucket_replication_config.destination_storage_class,
        var.s3_bucket_replication_config.role_name,
        var.s3_bucket_replication_config.policy_name,
        var.s3_bucket_replication_config.destination_kms_key_arn,
      ] : v != null && v != ""
    ])
    error_message = "When s3_bucket_replication_config.enabled is true, destination_bucket_name, destination_account_id, destination_storage_class, role_name, policy_name, and destination_kms_key_arn must all be set."
  }

  default = {}
}
