data "aws_iam_policy_document" "github_actions" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:*Object",
      "kms:Decrypt",
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:DeleteItem",

      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:GetRole",
      "iam:ListRolePolicies",
      "iam:GetRolePolicy",
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "iam:ListAttachedRolePolicies",
    ]

    resources = concat(
      [
        aws_s3_bucket.state.arn,
        "${aws_s3_bucket.state.arn}/*",
        aws_kms_key.this.arn,
      ],
      var.enable_dynamodb_locking ? [aws_dynamodb_table.terraform[0].arn] : [],
      local.datadog_resource_arns,
    )
  }
}

resource "aws_iam_role" "github_action_role" {
  count = var.enable_github_oidc ? 1 : 0

  name               = "github_actions_role"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role[0].json
}

resource "aws_iam_role_policy" "github_actions_policy" {
  count = var.enable_github_oidc ? 1 : 0

  name   = "github-actions-policy-bootstrapping"
  role   = aws_iam_role.github_action_role[0].name
  policy = data.aws_iam_policy_document.github_actions.json
}
