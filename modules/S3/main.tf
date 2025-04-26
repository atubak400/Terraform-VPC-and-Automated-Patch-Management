resource "random_id" "bucket_id" {
  byte_length = 4
}

resource "aws_s3_bucket" "simple_bucket" {
  bucket        = "simple-terraform-bucket-${random_id.bucket_id.hex}"
  force_destroy = true

  tags = {
    Name = "Simple-S3-Bucket"
  }
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.simple_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  bucket = aws_s3_bucket.simple_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

output "bucket_name" {
  value = aws_s3_bucket.simple_bucket.bucket
}
