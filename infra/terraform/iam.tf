locals {
  cw_namespace = "BackendSpringAWS"
}

resource "aws_iam_role" "ec2_role" {
  name               = "${var.project_name}-${var.environment}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust.json
}

data "aws_iam_policy_document" "ec2_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-${var.environment}-instance-profile"
  role = aws_iam_role.ec2_role.name
}

# Inline policy allowing access to S3 buckets and CloudWatch logs/metrics
resource "aws_iam_role_policy" "ec2_policy" {
  name = "${var.project_name}-${var.environment}-ec2-policy"
  role = aws_iam_role.ec2_role.id

  policy = data.aws_iam_policy_document.ec2_inline.json
}

data "aws_iam_policy_document" "ec2_inline" {
  statement {
    sid = "ArtifactRead"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.artifact.arn,
      "${aws_s3_bucket.artifact.arn}/*"
    ]
  }
  statement {
    sid = "AppBucketRW"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.app.arn,
      "${aws_s3_bucket.app.arn}/*"
    ]
  }
  statement {
    sid = "CloudWatchMetrics"
    actions = [
      "cloudwatch:PutMetricData"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "cloudwatch:namespace"
      values   = [local.cw_namespace]
    }
  }
  statement {
    sid = "CloudWatchLogs"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]
    resources = [
      aws_cloudwatch_log_group.app.arn,
      "${aws_cloudwatch_log_group.app.arn}:*"
    ]
  }
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/${var.project_name}/${var.environment}/app"
  retention_in_days = 7
  tags = {
    Environment = var.environment
  }
}

