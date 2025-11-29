terraform {
  required_version = "~> 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.awsRegion
}

locals {
  roleName = "snowflakeS3AccessRole"
}

data "aws_iam_policy_document" "trust" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [var.snowflakeIamUserArn]
    }
    actions = ["sts:AssumeRole"]
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.snowflakeExternalId]
    }
  }
}

data "aws_iam_policy_document" "s3_access" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion"
    ]
    resources = ["arn:aws:s3:::${var.s3BucketName}/${var.s3ProcessedPrefix}*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = ["arn:aws:s3:::${var.s3BucketName}"]
    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["${var.s3ProcessedPrefix}*"]
    }
  }
}

resource "aws_iam_role" "snowflake" {
  name               = local.roleName
  description        = "IAM role for Snowflake to access S3 processed data"
  assume_role_policy = data.aws_iam_policy_document.trust.json
}

resource "aws_iam_role_policy" "snowflake_s3" {
  name   = "${local.roleName}-policy"
  role   = aws_iam_role.snowflake.id
  policy = data.aws_iam_policy_document.s3_access.json
}
