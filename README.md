# Terraform-Based AWS VPC Automation with Security Compliance and Patching

## Introduction

The goal of this project was to create a fully automated, secure, and compliant AWS infrastructure using Terraform. Rather than manually setting up resources, we decided to use **modular Terraform** code to make the environment scalable, maintainable, and reusable. The final system includes a Virtual Private Cloud (VPC), an EC2 instance with access controls, an S3 bucket for audit logs, CloudTrail and AWS Config for compliance, and an AWS Lambda function to automate EC2 patching. This README explains every major decision, setup process, and result achieved in carrying out the project.

---

## Table of Contents

- [Planning and Design](#planning-and-design)
- [Building Each Part](#building-each-part)
  - [VPC Setup](#vpc-setup)
  - [EC2 Setup](#ec2-setup)
  - [IAM Setup](#iam-setup)
  - [S3 Bucket Setup](#s3-bucket-setup)
  - [CloudTrail Setup](#cloudtrail-setup)
  - [AWS Config Setup](#aws-config-setup)
  - [Lambda for Automated Patching](#lambda-for-automated-patching)
- [Testing](#testing)
- [Challenges and Solutions](#challenges-and-solutions)
- [Final Result](#final-result)
- [Future Improvements](#future-improvements)
- [Conclusion](#conclusion)

---

## Planning and Design

We decided to organize the project into **separate modules** for each AWS service (VPC, EC2, IAM, S3, CloudTrail, AWS Config, Lambda) to keep the code clean. Each module was made independent, so that we could reuse or update one service without affecting others. Terraform's modular design principles help achieve professional-grade infrastructure-as-code.

The **order of building** the services was important:
- First, **VPC** networking had to be created, because every AWS resource (EC2, Subnet, Route Table) depends on the network.
- Next, **IAM roles** were needed to ensure security and allow EC2 and Lambda permissions.
- Then, we provisioned **EC2**, because it depends on VPC and IAM roles.
- After compute, we created **S3 buckets** for audit logs.
- **CloudTrail** and **AWS Config** came next to enable compliance tracking.
- Finally, we built a **Lambda function** to automate patch management, tying everything together.

This step-by-step dependency management is critical for successful Terraform deployments.

---

## Building Each Part

### VPC Setup

We created a simple but functional VPC with a CIDR block of 10.0.0.0/16. Inside it, we created a single **public subnet**. An **Internet Gateway** was attached to allow internet access, and a **Route Table** with a default route to the internet was associated with the subnet.

We also created a **Security Group** that allowed inbound SSH (port 22) from anywhere for administrative access. This was flagged as a potential security risk, but acceptable for testing purposes.

The VPC outputs included the VPC ID, Subnet ID, and Security Group ID, which were passed to other modules like EC2 and Lambda.

### EC2 Setup

We launched an **EC2 instance** (Ubuntu 22.04) inside the VPC. The instance was assigned:
- The public subnet
- The SSH Security Group
- An IAM instance profile that granted it permissions to use AWS Systems Manager (SSM) and Secrets Manager.

The EC2 was critical because it was the resource we planned to patch automatically using Lambda later.

### IAM Setup

We created two main IAM configurations:
- An **IAM Role** for the EC2 instance, with policies:
  - `AmazonSSMManagedInstanceCore` (for SSM access)
  - `SecretsManagerReadWrite` (for secret retrieval)
- A separate **IAM Role** for the Lambda function to:
  - Send SSM commands
  - Describe EC2 instances

We avoided attaching overly broad policies to follow best practices of minimal permissions.

### S3 Bucket Setup

We created an **S3 bucket** specifically to store **CloudTrail logs**. It had a random suffix to avoid name collisions. A strict bucket policy was applied to allow only the `cloudtrail.amazonaws.com` service to write logs.

### CloudTrail Setup

We configured **CloudTrail** to capture all API calls across the AWS account and send them to the S3 bucket. Multi-region and log file validation were enabled for extra security.

Testing showed that actions like "StopInstances" and "StartInstances" were correctly logged in CloudTrail.

### AWS Config Setup

To ensure compliance and detect changes, we set up **AWS Config**. We created:
- A **Configuration Recorder** to track all supported resource types.
- A **Delivery Channel** that sends snapshots and changes to the same S3 bucket used by CloudTrail.
- An IAM Role with inline policies allowing AWS Config to interact with S3.

AWS Config dashboard confirmed that VPCs, EC2 instances, and IAM roles were being tracked successfully.

### Lambda for Automated Patching

We created a **Lambda function** that:
- Queries EC2 instances that have a `Patch=True` tag
- Sends an `AWS-RunPatchBaseline` command via SSM to install patches

This design is scalable because:
- Any future EC2 that needs patching only needs the `Patch=True` tag.
- No code changes needed for new instances.

The Lambda was deployed from a zipped Python script, and we used EventBridge to schedule it to run automatically.

---

## Testing

After building everything, thorough manual testing was carried out:

- **VPC**: Successfully launched EC2 into subnet, accessed internet.
- **CloudTrail**: API calls were captured and visible in Event History.
- **AWS Config**: Resource snapshots and changes appeared correctly.
- **Lambda**: Test runs showed either patch commands being sent or a message saying "No instances found".

Timeout errors in Lambda were solved by increasing the timeout setting from 3 seconds to 1 minute. IAM policy issues were debugged by reviewing service documentation and correctly setting minimal permissions.

---

## Challenges and Solutions

| Challenge | Solution |
|:---|:---|
| CloudTrail errors due to S3 policy | Created and attached the correct bucket policy manually |
| AWS Config role errors | Switched from managed policies to creating a custom inline policy |
| Lambda timeout errors | Increased timeout from default 3s to 60s |
| EC2 AMI ID not found | Used AWS CLI to fetch a valid Ubuntu AMI for eu-west-2 |
| Lambda finding no instances | Realized EC2 needed correct `Patch=True` tag |

Each challenge taught practical lessons about AWS service interdependencies and Terraform troubleshooting.

---

## Final Result

The project successfully delivered a production-quality, compliant, and automated environment:

- **VPC**: Clean, modular, with internet access.
- **EC2**: Secure, SSM-enabled.
- **IAM**: Properly scoped permissions.
- **S3**: Secure audit log storage.
- **CloudTrail**: Capturing all API activity.
- **AWS Config**: Tracking all resource changes.
- **Lambda**: Automatic EC2 patching triggered on schedule.

Infrastructure was fully reproducible by running a single `terraform apply`.

---

## Future Improvements

- Add **CloudWatch alarms** to monitor Lambda patching success.
- Improve **patching scripts** to notify by SNS or Slack.
- Expand to **private subnets** and add NAT Gateways.
- Implement **Config Rules** for additional compliance checking.
- Add **Terraform Workspaces** to manage dev/stage/prod environments separately.
- Introduce **KMS encryption** for S3 bucket logs.

These improvements would harden the environment further and bring it to full enterprise-level operations.

---

## Conclusion

This project was a complete hands-on demonstration of planning, building, testing, and automating a secure AWS environment using Terraform. Every key AWS service — VPC, EC2, IAM, S3, CloudTrail, Config, and Lambda — was used properly with best practices. We emphasized modularity, security, compliance, and automation. The result is a powerful, scalable foundation for any production AWS infrastructure.

---

Thank you for following through! 🚀
