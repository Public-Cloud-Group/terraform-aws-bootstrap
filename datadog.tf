data "aws_secretsmanager_secret" "opsgenie_api_key" {
  count = var.enable_datadog_permissions ? 1 : 0
  name  = var.opsgenie_secret_name
}

data "aws_secretsmanager_secret" "datadog_keys" {
  count = var.enable_datadog_permissions ? 1 : 0
  name  = var.datadog_keys_secret_name
}

data "aws_iam_policy" "datadog_integration_policy" {
  count = var.enable_datadog_permissions ? 1 : 0
  name  = var.datadog_integration_policy_name
}

data "aws_iam_role" "datadog_integration_role" {
  count = var.enable_datadog_permissions ? 1 : 0
  name  = var.datadog_integration_role_name
}


