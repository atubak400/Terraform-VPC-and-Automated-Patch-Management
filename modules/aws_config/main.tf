variable "cloudtrail_bucket_name" {}

resource "aws_config_configuration_recorder" "main" {
  name     = "simple-recorder"
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported = true
    include_global_resource_types = true
  }
}

resource "aws_config_delivery_channel" "main" {
  name           = "simple-delivery-channel"
  s3_bucket_name = var.cloudtrail_bucket_name
  depends_on     = [aws_config_configuration_recorder.main]
}

resource "aws_config_configuration_recorder_status" "main" {
  name       = aws_config_configuration_recorder.main.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.main]
}

resource "aws_iam_role" "config_role" {
  name = "ConfigRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "config.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "config_role_inline_policy" {
  name = "ConfigRolePolicy"
  role = aws_iam_role.config_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetBucketAcl",
          "sns:Publish",
          "config:Put*",
          "config:Get*",
          "config:Describe*",
          "ec2:Describe*",
          "iam:List*",
          "iam:Get*"
        ],
        Resource = "*"
      }
    ]
  })
}
