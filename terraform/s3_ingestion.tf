locals {
  regaffairs_bucket_name = coalesce(var.regaffairs_documents_bucket_name, "${var.project_name}-regaffairs-documents")
}

resource "aws_kms_key" "regaffairs_docs" {
  count = var.enable_regaffairs_ingestion ? 1 : 0

  description             = "KMS key for Regulatory Affairs documents bucket"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = {
    Name = "regaffairs-docs-kms-key"
  }
}

resource "aws_kms_alias" "regaffairs_docs" {
  count = var.enable_regaffairs_ingestion ? 1 : 0

  name          = "alias/${var.project_name}-regaffairs-docs"
  target_key_id = aws_kms_key.regaffairs_docs[0].key_id
}

resource "aws_s3_bucket" "regaffairs_documents" {
  count = var.enable_regaffairs_ingestion ? 1 : 0

  bucket = local.regaffairs_bucket_name

  tags = {
    Name = "regaffairs-documents"
  }
}

resource "aws_s3_bucket_versioning" "regaffairs_documents" {
  count = var.enable_regaffairs_ingestion ? 1 : 0

  bucket = aws_s3_bucket.regaffairs_documents[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "regaffairs_documents" {
  count = var.enable_regaffairs_ingestion ? 1 : 0

  bucket = aws_s3_bucket.regaffairs_documents[0].id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.regaffairs_docs[0].arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "regaffairs_documents" {
  count = var.enable_regaffairs_ingestion ? 1 : 0

  bucket = aws_s3_bucket.regaffairs_documents[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "regaffairs_documents" {
  count = var.enable_regaffairs_ingestion ? 1 : 0

  bucket = aws_s3_bucket.regaffairs_documents[0].id

  rule {
    id     = "expire-noncurrent-versions"
    status = "Enabled"
    filter {}

    noncurrent_version_expiration {
      noncurrent_days = var.regaffairs_noncurrent_version_expiration_days
    }
  }
}

data "aws_iam_policy_document" "regaffairs_documents_ssl_only" {
  count = var.enable_regaffairs_ingestion ? 1 : 0

  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:*"]

    resources = [
      aws_s3_bucket.regaffairs_documents[0].arn,
      "${aws_s3_bucket.regaffairs_documents[0].arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "regaffairs_documents_ssl_only" {
  count = var.enable_regaffairs_ingestion ? 1 : 0

  bucket = aws_s3_bucket.regaffairs_documents[0].id
  policy = data.aws_iam_policy_document.regaffairs_documents_ssl_only[0].json
}
