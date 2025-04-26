#!/bin/bash

# Create project folder
mkdir terraform-simple-vpc
cd terraform-simple-vpc

# Create main.tf with full Terraform code
cat <<EOF > main.tf
provider "aws" {
  region = "eu-west-2" # London
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Simple-VPC"
  }
}

output "vpc_id" {
  value = aws_vpc.main.id
}
EOF

echo "✅ Project 'terraform-simple-vpc' created with main.tf!"
echo "👉 Now run:"
echo "cd terraform-simple-vpc"
echo "terraform init"
echo "terraform apply"
