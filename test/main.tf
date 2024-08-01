```hcl
# Define AWS provider
provider "aws" {
  region = "us-east-1" # Replace with your desired region
}

# Use VPC module
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

# Use S3 bucket module
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.0"

  bucket = "my-s3-bucket"
  acl    = "private"
}

# Use EC2 instance module
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 4.0"

  name = "my-ec2-instance"

  instance_type = "t2.micro"
  ami           = "ami-0747bdcabd34c712a" # Replace with your desired AMI
  key_name      = "my-key-pair"            # Replace with your key pair name

  vpc_security_group_ids = [module.vpc.default_security_group_id]
  subnet_id              = module.vpc.private_subnets[0]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World!" > /tmp/hello.txt
              EOF
}

# Use CloudWatch module
resource "aws_cloudwatch_log_group" "my_log_group" {
  name = "my-log-group"
}

# Define output values
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "s3_bucket_id" {
  description = "S3 Bucket ID"
  value       = module.s3_bucket.s3_bucket_id
}

output "ec2_instance_id" {
  description = "EC2 Instance ID"
  value       = module.ec2_instance.id
}

output "cloudwatch_log_group_name" {
  description = "CloudWatch Log Group Name"
  value       = aws_cloudwatch_log_group.my_log_group.name
}
```

This Terraform code defines an AWS provider and uses several modules to create resources based on the architecture diagram:

1. **VPC Module**: Creates a VPC with public and private subnets, NAT Gateway, and VPN Gateway.
2. **S3 Bucket Module**: Creates an S3 bucket with private access control.
3. **EC2 Instance Module**: Creates an EC2 instance in one of the private subnets, with a user data script to write a "Hello, World!" message to a file.
4. **CloudWatch Log Group**: Creates a CloudWatch Log Group for logging purposes.

The output values provide the IDs and names of the created resources for reference.

Note: You may need to adjust the configuration values (e.g., region, AMI, key pair name) according to your specific requirements. Additionally, you might need to add additional resources or modules based on the architecture diagram's components.