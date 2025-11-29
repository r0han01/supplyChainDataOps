output "iam_role_arn" {
  description = "IAM role ARN for Snowflake storage integration"
  value       = aws_iam_role.snowflake.arn
}
