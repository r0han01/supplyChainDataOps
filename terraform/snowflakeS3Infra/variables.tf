variable "awsRegion" {
  description = "AWS region for S3 bucket and IAM role"
  type        = string
  default     = "us-east-1"
}

variable "yourAwsAccountId" {
  description = "Your AWS account ID (used for initial role creation)"
  type        = string
}

variable "s3BucketName" {
  description = "S3 bucket name containing processed files"
  type        = string
}

variable "s3ProcessedPrefix" {
  description = "S3 prefix path for processed files"
  type        = string
  default     = "processed/"
}

variable "snowflakeIamUserArn" {
  description = "Snowflake IAM user ARN from storage integration (leave empty for Phase 1)"
  type        = string
  default     = ""
}

variable "snowflakeExternalId" {
  description = "Snowflake external ID from storage integration (leave empty for Phase 1)"
  type        = string
  default     = ""
}
