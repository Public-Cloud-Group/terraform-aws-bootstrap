data "aws_iam_policy_document" "gitlab_ci" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:*Object",
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:DeleteItem",
      "kms:Decrypt",
      "kms:GenerateDataKey",
      "kms:DescribeKey",
      "kms:Encrypt",
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

resource "aws_iam_role" "gitlab_ci_role" {
  count = var.enable_gitlab_oidc ? 1 : 0

  name               = "gitlab_ci_role"
  assume_role_policy = data.aws_iam_policy_document.gitlab_ci_assume_role[0].json
}

resource "aws_iam_role_policy" "gitlab_ci_policy" {
  count = var.enable_gitlab_oidc ? 1 : 0

  name   = "gitlab-ci-policy-bootstrapping"
  role   = aws_iam_role.gitlab_ci_role[0].name
  policy = data.aws_iam_policy_document.gitlab_ci.json
}
