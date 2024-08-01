```hcl
# Configure AWS provider
provider "aws" {
  region = "us-east-1"
}

# S3 bucket for file uploads
module "file_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  bucket = "testbucketpocforbedrock"
  acl    = "private"
}

# S3 bucket notification for object create/update events
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = module.file_bucket.s3_bucket_id

  lambda_function {
    lambda_function_arn = aws_lambda_function.process_file.arn
    events              = ["s3:ObjectCreated:*", "s3:ObjectUpdated:*"]
  }
}

# Lambda function to process the file and generate summary/PDF
resource "aws_lambda_function" "process_file" {
  filename         = "process_file.zip"
  function_name    = "process-file"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "index.handler"
  runtime          = "nodejs14.x"
}

# IAM role for Lambda execution
resource "aws_iam_role" "lambda_exec" {
  name = "lambda-execution-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# CloudWatch log group for Lambda logs
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/process-file"
  retention_in_days = 7
}
```

This Terraform code sets up the following resources:

1. An AWS provider in the `us-east-1` region.
2. An S3 bucket named `testbucketpocforbedrock` with private ACL using the `terraform-aws-modules/s3-bucket/aws` module.
3. An S3 bucket notification that triggers the `process_file` Lambda function whenever an object is created or updated in the S3 bucket.
4. A Lambda function named `process-file` with the provided `process_file.zip` code, using Node.js 14.x runtime, and the specified IAM role.
5. An IAM role named `lambda-execution-role` with the necessary permissions for Lambda execution.
6. A CloudWatch log group named `/aws/lambda/process-file` with a retention period of 7 days for Lambda logs.

Note: This code assumes that the `process_file.zip` file containing the Lambda function code is present in the same directory as the Terraform configuration.