resource "aws_iam_user" "UserA" {
  name          = "UserA"
  path          = "/"
}

resource "aws_iam_user_login_profile" "UserA" {
  user    = aws_iam_user.UserA.name
}

output "UserA_password" {
  value = aws_iam_user_login_profile.UserA.password
}

resource "aws_iam_user" "UserB" {
  name          = "UserB"
  path          = "/"
}

resource "aws_iam_user_login_profile" "UserB" {
  user    = aws_iam_user.UserB.name
}

output "UserB_password" {
  value = aws_iam_user_login_profile.UserB.password
}


resource "aws_iam_user_policy_attachment" "UserA" {
  policy_arn = aws_iam_policy.s3_input_bucket_read_write_policy.arn
  user       = "UserA"
  depends_on = [
    aws_iam_user.UserA
  ]
}

resource "aws_iam_user_policy_attachment" "UserB" {
  policy_arn = aws_iam_policy.s3_processed_bucket_read_only_policy.arn
  user       = "UserB"
  depends_on = [
    aws_iam_user.UserB
  ]
}


resource "aws_iam_policy" "s3_input_bucket_read_write_policy" {
  name = "S3-Read-Write-Input-Bucket"
  path = "/"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetBucketLocation",
        "s3:ListAllMyBuckets"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["arn:aws:s3:::image-processor-input"]
    },
    {
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::image-processor-input/*"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "s3_processed_bucket_read_only_policy" {
  name = "S3-Read-Only-Processed-Bucket"
  path = "/"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetBucketLocation",
        "s3:ListAllMyBuckets"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["arn:aws:s3:::image-processor-processed"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": ["arn:aws:s3:::image-processor-processed/*"]
    }
  ]
}
POLICY
}

