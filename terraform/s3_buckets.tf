resource "aws_s3_bucket" "s3_bucket_a" {
  bucket = "s3-bucket-a"

  tags = {
    Name        = "bucket a - input"
  }
}

resource "aws_s3_bucket_acl" "s3_bucket_a" {
  bucket = aws_s3_bucket.s3_bucket_a.id
  acl    = "private"
}
