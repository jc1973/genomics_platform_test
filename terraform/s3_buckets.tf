resource "aws_s3_bucket" "s3_bucket_source" {
  bucket = "${var.project_name}-source"

  tags = {
    Name = "${var.project_name} - source"
  }
}

resource "aws_s3_bucket_acl" "s3_bucket_source" {
  bucket = aws_s3_bucket.s3_bucket_source.id
  acl    = "private"
}

resource "aws_s3_bucket" "s3_bucket_processed" {
  bucket = "${var.project_name}-processed"

  tags = {
    Name = "${var.project_name} - processed"
  }
}

resource "aws_s3_bucket_acl" "s3_bucket_processed" {
  bucket = aws_s3_bucket.s3_bucket_processed.id
  acl    = "private"
}

