variable "subnet_id" {}
variable "security_group_id" {}
variable "instance_profile_name" {}


resource "aws_instance" "web" {
  ami                    = "ami-0eb260c4d5475b901"
  instance_type          = "t2.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile   = var.instance_profile_name
  user_data = file("${path.module}/user_data.sh")

  tags = {
    Name = "Simple-EC2"
  }
}

