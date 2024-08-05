```
# main.tf
module "input_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  bucket  = var.input_bucket_name
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = module.input_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.process_file.arn
    events              = ["s3:ObjectCreated:*"]
  }
}

resource "aws_lambda_function" "process_file" {
  filename         = var.lambda_function_payload
  function_name    = "process-file"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "index.handler"
  runtime          = "nodejs14.x"
  source_code_hash = filebase64sha256(var.lambda_function_payload)
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda-execution-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/process-file"
  retention_in_days = var.log_retention_days
}

# variables.tf
variable "input_bucket_name" {
  description = "Name of the S3 bucket for input files"
  type        = string
}

variable "lambda_function_payload" {
  description = "Path to the Lambda function payload ZIP file"
  type        = string
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 7
}

# outputs.tf
output "input_bucket_name" {
  description = "Name of the S3 bucket for input files"
  value       = module.input_bucket.id
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.process_file.function_name
}
```