module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "${var.project_name}-lambda"
  description   = "strip exif data from images"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"

  create_package         = false
    local_existing_package = "../lambda_function/archive.zip"

#    source_path = "../lambda_function"

  tags = {
    Name = "${var.project_name}-lambda"
  }

  attach_policies = true
  policies           = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole","arn:aws:iam::aws:policy/AmazonS3FullAccess"]
  number_of_policies = 2
  
}
