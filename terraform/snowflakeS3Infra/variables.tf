variable "awsRegion" {
  description = "AWS region for S3 bucket and IAM role"
  type        = string
  default     = "us-east-1"
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
  description = "Snowflake IAM user ARN from storage integration"
  type        = string
}

variable "snowflakeExternalId" {
  description = "Snowflake external ID from storage integration"
  type        = string
}
