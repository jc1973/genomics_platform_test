module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "image-process"
  description   = "strip exif data from images"
  handler       = "index.lambda_handler"
  runtime       = "python3.9"

  create_package         = false
  local_existing_package = "../lambda_function/archive.zip"

  tags = {
    Name = "image-processor-lambda"
  }
}
