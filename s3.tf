resource "aws_s3_bucket" "state" {
  bucket = local.state_bucket_name
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.this.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket                  = aws_s3_bucket.state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "state_force_ssl" {
  statement {
    sid     = "AllowSSLRequestsOnly"
    actions = ["s3:*"]
    effect  = "Deny"

    resources = [
      aws_s3_bucket.state.arn,
      "${aws_s3_bucket.state.arn}/*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "state_force_ssl" {
  bucket = aws_s3_bucket.state.id
  policy = data.aws_iam_policy_document.state_force_ssl.json
}

# Optional: enable s3 bucket replication
locals {
  destination_bucket_arn = var.s3_bucket_replication_config.enabled ? "arn:aws:s3:::${var.s3_bucket_replication_config.destination_bucket_name}" : null
}

data "aws_iam_policy_document" "replication_assume_role" {
  count = var.s3_bucket_replication_config.enabled ? 1 : 0
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "replication" {
  count              = var.s3_bucket_replication_config.enabled ? 1 : 0
  name               = var.s3_bucket_replication_config.role_name
  assume_role_policy = data.aws_iam_policy_document.replication_assume_role[0].json
}

data "aws_iam_policy_document" "replication" {
  count = var.s3_bucket_replication_config.enabled ? 1 : 0
  statement {
    sid    = "SourceBucketReadPermissions"
    effect = "Allow"

    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
    ]

    resources = [aws_s3_bucket.state.arn]
  }

  statement {
    sid    = "SourceObjectReadPermissions"
    effect = "Allow"

    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
    ]

    resources = ["${aws_s3_bucket.state.arn}/*"]
  }

  statement {
    sid    = "DestinationObjectWritePermissions"
    effect = "Allow"

    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
      "s3:ObjectOwnerOverrideToBucketOwner",
    ]

    resources = ["${local.destination_bucket_arn}/*"]
  }

  statement {
    sid       = "AllowSourceKMSDecrypt"
    effect    = "Allow"
    actions   = ["kms:Decrypt", "kms:GenerateDataKey"]
    resources = [aws_kms_key.this.arn]
  }

  statement {
    sid       = "AllowDestinationKMSEncrypt"
    effect    = "Allow"
    actions   = ["kms:Encrypt", "kms:GenerateDataKey"]
    resources = [var.s3_bucket_replication_config.destination_kms_key_arn]
  }
}

resource "aws_iam_policy" "replication" {
  count  = var.s3_bucket_replication_config.enabled ? 1 : 0
  name   = var.s3_bucket_replication_config.policy_name
  policy = data.aws_iam_policy_document.replication[0].json
}

resource "aws_iam_role_policy_attachment" "replication" {
  count      = var.s3_bucket_replication_config.enabled ? 1 : 0
  role       = aws_iam_role.replication[0].name
  policy_arn = aws_iam_policy.replication[0].arn
}

resource "aws_s3_bucket_replication_configuration" "this" {
  count = var.s3_bucket_replication_config.enabled ? 1 : 0

  depends_on = [aws_s3_bucket_versioning.state]

  role   = aws_iam_role.replication[0].arn
  bucket = aws_s3_bucket.state.id

  rule {
    id     = "replication-to-mco-account"
    status = "Enabled"

    filter {}

    delete_marker_replication {
      status = "Enabled"
    }

    source_selection_criteria {
      sse_kms_encrypted_objects {
        status = "Enabled"
      }
    }

    destination {
      bucket        = local.destination_bucket_arn
      account       = var.s3_bucket_replication_config.destination_account_id
      storage_class = var.s3_bucket_replication_config.destination_storage_class

      access_control_translation {
        owner = "Destination"
      }

      encryption_configuration {
        replica_kms_key_id = var.s3_bucket_replication_config.destination_kms_key_arn
      }

      dynamic "metrics" {
        for_each = var.s3_bucket_replication_config.rtc_enabled ? [1] : []
        content {
          status = "Enabled"

          event_threshold {
            minutes = 15
          }
        }
      }

      dynamic "replication_time" {
        for_each = var.s3_bucket_replication_config.rtc_enabled ? [1] : []
        content {
          status = "Enabled"

          time {
            minutes = 15
          }
        }
      }
    }
  }
}
