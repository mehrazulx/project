data "aws_iam_policy_document" "datasync_assume_role" {
  count = var.enable_regaffairs_ingestion && var.enable_regaffairs_datasync ? 1 : 0

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["datasync.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "datasync_s3_access" {
  count = var.enable_regaffairs_ingestion && var.enable_regaffairs_datasync ? 1 : 0

  name               = "${var.project_name}-datasync-s3-access"
  assume_role_policy = data.aws_iam_policy_document.datasync_assume_role[0].json
}

data "aws_iam_policy_document" "datasync_s3_access" {
  count = var.enable_regaffairs_ingestion && var.enable_regaffairs_datasync ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads"
    ]
    resources = [aws_s3_bucket.regaffairs_documents[0].arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:AbortMultipartUpload",
      "s3:GetObjectTagging",
      "s3:PutObjectTagging"
    ]
    resources = ["${aws_s3_bucket.regaffairs_documents[0].arn}/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = [aws_kms_key.regaffairs_docs[0].arn]
  }
}

resource "aws_iam_role_policy" "datasync_s3_access" {
  count = var.enable_regaffairs_ingestion && var.enable_regaffairs_datasync ? 1 : 0

  name   = "${var.project_name}-datasync-s3-access"
  role   = aws_iam_role.datasync_s3_access[0].id
  policy = data.aws_iam_policy_document.datasync_s3_access[0].json
}

resource "aws_datasync_location_smb" "regaffairs_source" {
  count = var.enable_regaffairs_ingestion && var.enable_regaffairs_datasync ? 1 : 0

  agent_arns      = [var.datasync_agent_arn]
  domain          = var.smb_domain
  password        = var.smb_password
  server_hostname = var.smb_server_hostname
  subdirectory    = var.smb_subdirectory
  user            = var.smb_user

  mount_options {
    version = var.smb_mount_version
  }
}

resource "aws_datasync_location_s3" "regaffairs_destination" {
  count = var.enable_regaffairs_ingestion && var.enable_regaffairs_datasync ? 1 : 0

  s3_bucket_arn = aws_s3_bucket.regaffairs_documents[0].arn
  subdirectory  = var.regaffairs_s3_prefix

  s3_config {
    bucket_access_role_arn = aws_iam_role.datasync_s3_access[0].arn
  }
}

resource "aws_datasync_task" "regaffairs_weekly" {
  count = var.enable_regaffairs_ingestion && var.enable_regaffairs_datasync ? 1 : 0

  name                     = "${var.project_name}-regaffairs-weekly-sync"
  source_location_arn      = aws_datasync_location_smb.regaffairs_source[0].arn
  destination_location_arn = aws_datasync_location_s3.regaffairs_destination[0].arn

  schedule {
    schedule_expression = var.datasync_schedule_expression
  }

  options {
    verify_mode                    = "POINT_IN_TIME_CONSISTENT"
    transfer_mode                  = "CHANGED"
    preserve_deleted_files         = "PRESERVE"
    overwrite_mode                 = "ALWAYS"
    atime                          = "BEST_EFFORT"
    mtime                          = "PRESERVE"
    object_tags                    = "PRESERVE"
    bytes_per_second               = -1
    task_queueing                  = "ENABLED"
    log_level                      = "TRANSFER"
    posix_permissions              = "NONE"
    uid                            = "NONE"
    gid                            = "NONE"
    preserve_devices               = "NONE"
    security_descriptor_copy_flags = "OWNER_DACL"
  }

  includes {
    filter_type = "SIMPLE_PATTERN"
    value       = var.datasync_include_filter
  }
}
