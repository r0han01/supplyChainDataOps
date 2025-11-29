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

locals {
  # Phase 1: Use your AWS account ID if Snowflake values not provided
  # Phase 2: Use Snowflake IAM user ARN if provided
  trustPrincipal = var.snowflakeIamUserArn != "" ? var.snowflakeIamUserArn : "arn:aws:iam::${var.yourAwsAccountId}:root"
  
  # Only add External ID condition if Snowflake values are provided
  hasSnowflakeValues = var.snowflakeIamUserArn != "" && var.snowflakeExternalId != ""
}

data "aws_iam_policy_document" "trust" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [local.trustPrincipal]
    }
    actions = ["sts:AssumeRole"]
    
    # Only add External ID condition in Phase 2 (when Snowflake values exist)
    dynamic "condition" {
      for_each = local.hasSnowflakeValues ? [1] : []
      content {
        test     = "StringEquals"
        variable = "sts:ExternalId"
        values   = [var.snowflakeExternalId]
      }
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
