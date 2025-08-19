output "ec2_public_ip" {
  value       = aws_instance.app.public_ip
  description = "Public IP of the EC2 instance"
}

output "ec2_public_dns" {
  value       = aws_instance.app.public_dns
  description = "Public DNS of the EC2 instance"
}

output "rds_endpoint" {
  value       = aws_db_instance.postgres.address
  description = "RDS Postgres endpoint"
}

output "s3_app_bucket" {
  value       = aws_s3_bucket.app.bucket
  description = "S3 bucket for application files"
}

output "s3_artifact_bucket" {
  value       = aws_s3_bucket.artifact.bucket
  description = "S3 bucket for application artifacts (JAR)"
}

output "cloudwatch_log_group" {
  value       = aws_cloudwatch_log_group.app.name
  description = "CloudWatch Logs group for the app"
}

