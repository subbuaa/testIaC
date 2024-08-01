```hcl
# Use the VPC module to create a VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true
}

# Use the S3 Bucket module to create an S3 bucket
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.0"

  bucket = "my-s3-bucket"
  acl    = "private"
}

# Use the EC2 Instance module to create an EC2 instance
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "my-ec2-instance"

  instance_type = "t2.micro"
  ami           = "ami-0747bdcabd34c712a" # Replace with your desired AMI ID
  key_name      = "my-key-pair"            # Replace with your key pair name

  vpc_security_group_ids = [module.vpc.default_security_group_id]
  subnet_id              = module.vpc.private_subnets[0]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World!" > /tmp/hello.txt
              EOF
}

# Use the CloudWatch module to create a CloudWatch resource
module "cloudwatch" {
  source  = "terraform-aws-modules/cloudwatch/aws"
  version = "~> 2.0"

  log_group_name = "my-log-group"
}

# Define resources for event trigger, file processing, and summary/PDF generation
resource "aws_lambda_function" "event_trigger" {
  # ... Lambda function configuration for event trigger
}

resource "aws_lambda_function" "file_processing" {
  # ... Lambda function configuration for file processing
}

resource "aws_lambda_function" "summary_pdf_generation" {
  # ... Lambda function configuration for summary/PDF generation
}
```

This Terraform code creates the following resources:

1. A VPC with public and private subnets, NAT Gateway, and VPN Gateway using the `terraform-aws-modules/vpc/aws` module.
2. An S3 bucket with private ACL using the `terraform-aws-modules/s3-bucket/aws` module.
3. An EC2 instance in the private subnet of the VPC using the `terraform-aws-modules/ec2-instance/aws` module.
4. A CloudWatch log group using the `terraform-aws-modules/cloudwatch/aws` module.
5. Three Lambda functions for event trigger, file processing, and summary/PDF generation (configurations not included).

Note: You will need to replace the placeholders (e.g., AMI ID, key pair name) with your desired values and provide the necessary configurations for the Lambda functions.