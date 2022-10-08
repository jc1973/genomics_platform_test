module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "${var.project_name}-lambda"
  description   = "strip exif data from images"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"


  source_path = "../exif_lamba_function"

  tags = {
    Name = "${var.project_name}-lambda"
  }

  attach_policies    = true
  policies           = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole", "arn:aws:iam::aws:policy/AmazonS3FullAccess"]
  number_of_policies = 2

}

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


resource "aws_s3_bucket" "s3_bucket_input" {
  bucket = "${var.project_name}-input"

  tags = {
    Name = "${var.project_name} - input"
  }
}

resource "aws_s3_bucket_acl" "s3_bucket_input" {
  bucket = aws_s3_bucket.s3_bucket_input.id
  acl    = "private"
}

# Trigger lambda function when a file is put in s3 bucket
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.s3_bucket_input.id
  lambda_function {
    lambda_function_arn = module.lambda_function.lambda_function_arn
    events              = ["s3:ObjectCreated:Put"]

  }
}

resource "aws_lambda_permission" "input_bucket" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_function.lambda_function_arn
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${aws_s3_bucket.s3_bucket_input.id}"
}

