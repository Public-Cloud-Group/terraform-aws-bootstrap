data "tls_certificate" "gitlab" {
  count = var.enable_gitlab_oidc ? 1 : 0
  url   = "${var.gitlab_url}/.well-known/openid-configuration"
}

resource "aws_iam_openid_connect_provider" "gitlab" {
  count           = var.enable_gitlab_oidc ? 1 : 0
  url             = var.gitlab_url
  client_id_list  = [var.gitlab_url]
  thumbprint_list = [data.tls_certificate.gitlab[0].certificates[0].sha1_fingerprint]
}

data "aws_iam_policy_document" "gitlab_ci_assume_role" {
  count = var.enable_gitlab_oidc ? 1 : 0

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.gitlab[0].arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${trimprefix(var.gitlab_url, "https://")}:aud"
      values   = [var.gitlab_url]
    }

    condition {
      test     = "StringLike"
      variable = "${trimprefix(var.gitlab_url, "https://")}:sub"
      values   = [var.gitlab_oidc_project]
    }
  }
}
