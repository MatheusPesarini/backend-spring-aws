data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["137112412989"] # Amazon
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

locals {
  first_public_subnet_id = values(aws_subnet.public)[0].id
  cw_namespace           = "BackendSpringAWS"
}

resource "aws_instance" "app" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  subnet_id              = local.first_public_subnet_id
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  key_name               = var.key_name

  user_data = templatefile("${path.module}/templates/user_data.sh.tftpl", {
    region            = var.region
    artifact_bucket   = aws_s3_bucket.artifact.bucket
    app_jar_key       = var.app_jar_key
    app_port          = var.app_port
    s3_bucket         = aws_s3_bucket.app.bucket
    db_url            = "jdbc:postgresql://${aws_db_instance.postgres.address}:5432/${var.db_name}"
    db_username       = var.db_username
    db_password       = var.db_password
    log_group_name    = aws_cloudwatch_log_group.app.name
    enable_cw_agent   = var.enable_cloudwatch
    cw_namespace      = local.cw_namespace
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-ec2"
    Environment = var.environment
  }
}

