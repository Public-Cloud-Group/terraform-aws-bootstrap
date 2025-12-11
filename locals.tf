locals {
  state_bucket_name = var.state_bucket_name != "" ? var.state_bucket_name : "terraform-state-${var.aws_account_id}"

  datadog_resource_arns = var.enable_datadog_permissions ? [
    data.aws_iam_policy.datadog_integration_policy[0].arn,
    data.aws_secretsmanager_secret.opsgenie_api_key[0].arn,
    data.aws_secretsmanager_secret.datadog_keys[0].arn,
    data.aws_iam_role.datadog_integration_role[0].arn,
  ] : []
}
