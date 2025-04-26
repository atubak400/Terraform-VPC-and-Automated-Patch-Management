provider "aws" {
  region = "eu-west-2"
}

module "vpc" {
  source   = "./modules/vpc"
  vpc_cidr = "10.0.0.0/16"
}

module "iam" {
  source = "./modules/iam"
}

module "ec2" {
  source                = "./modules/ec2"
  subnet_id             = module.vpc.subnet_id
  security_group_id     = module.vpc.security_group_id
  instance_profile_name = module.iam.instance_profile_name
}

module "s3" {
  source = "./modules/S3"
}

module "cloudtrail" {
  source = "./modules/cloudtrail"
}

module "aws_config" {
  source = "./modules/aws_config"
  cloudtrail_bucket_name = module.cloudtrail.cloudtrail_bucket_name
}

module "lambda_patch" {
  source = "./modules/lambda_patch"
}
