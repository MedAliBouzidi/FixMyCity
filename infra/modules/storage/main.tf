data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_elb_service_account" "main" {}

locals {
  suffix               = var.bucket_suffix == "" ? "" : "-${var.bucket_suffix}"
  media_bucket_name    = "${var.project_name}-media-${var.environment}${local.suffix}"
  archives_bucket_name = "${var.project_name}-archives-${var.environment}${local.suffix}"
  account_id           = data.aws_caller_identity.current.account_id
}

# ===================== MEDIA =====================
resource "aws_s3_bucket" "media" {
  bucket        = local.media_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "media" {
  bucket                  = aws_s3_bucket.media.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = !var.media_public_read
  restrict_public_buckets = !var.media_public_read
}

resource "aws_s3_bucket_cors_configuration" "media" {
  bucket = aws_s3_bucket.media.id

  cors_rule {
    allowed_methods = ["PUT", "GET"]
    allowed_origins = var.cors_allowed_origins
    allowed_headers = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

data "aws_iam_policy_document" "media_public" {
  count = var.media_public_read ? 1 : 0

  statement {
    sid       = "PublicReadMediaPrefix"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.media.arn}${var.media_path_pattern}"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "media" {
  count      = var.media_public_read ? 1 : 0
  bucket     = aws_s3_bucket.media.id
  policy     = data.aws_iam_policy_document.media_public[0].json
  depends_on = [aws_s3_bucket_public_access_block.media]
}

# ===================== ARCHIVES =====================
resource "aws_s3_bucket" "archives" {
  bucket        = local.archives_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "archives" {
  bucket                  = aws_s3_bucket.archives.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "archives" {
  bucket = aws_s3_bucket.archives.id

  rule {
    id     = "expire-after-30-days"
    status = "Enabled"
    filter {}
    expiration {
      days = 30
    }
  }
}

data "aws_iam_policy_document" "archives" {
  statement {
    sid     = "AllowALBAccessLogs"
    effect  = "Allow"
    actions = ["s3:PutObject"]
    resources = [
      "${aws_s3_bucket.archives.arn}/AWSLogs/${local.account_id}/*",
      "${aws_s3_bucket.archives.arn}/*/AWSLogs/${local.account_id}/*",
    ]
    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.main.arn]
    }
  }

  statement {
    sid       = "AllowCloudWatchLogsAclCheck"
    effect    = "Allow"
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.archives.arn]
    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.current.name}.amazonaws.com"]
    }
  }

  statement {
    sid       = "AllowCloudWatchLogsExport"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.archives.arn}/cloudwatch/*"]
    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.current.name}.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

resource "aws_s3_bucket_policy" "archives" {
  bucket     = aws_s3_bucket.archives.id
  policy     = data.aws_iam_policy_document.archives.json
  depends_on = [aws_s3_bucket_public_access_block.archives]
}