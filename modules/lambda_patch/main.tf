resource "aws_iam_role" "lambda_patch_role" {
  name = "LambdaPatchEC2Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "Lambda-Patch-Role"
  }
}

resource "aws_iam_role_policy" "lambda_patch_policy" {
  name = "LambdaPatchPolicy"
  role = aws_iam_role.lambda_patch_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ssm:SendCommand",
          "ssm:ListCommands",
          "ec2:DescribeInstances",
          "iam:PassRole"
        ],
        Resource = "*"
      }
    ]
  })
}


resource "aws_lambda_function" "patch_instances" {
  function_name = "patch-instances"

  filename         = "${path.module}/../../lambda_code/patch_instances.zip"
  handler          = "patch_instances.lambda_handler"
  runtime          = "python3.9"
  role             = aws_iam_role.lambda_patch_role.arn

  source_code_hash = filebase64sha256("${path.module}/../../lambda_code/patch_instances.zip")
}
