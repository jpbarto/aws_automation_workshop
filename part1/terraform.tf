provider "aws" {
    region = "us-east-1"
}

resource "aws_iam_policy" "region_restriction_policy" {
  name       = "RegionRestrictionPolicy"

  lifecycle {
    create_before_destroy = true
  }

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Deny",
            "NotAction": [
                "aws-portal:*",
                "iam:*",
                "s3:read*",
                "s3:list*",
                "support:*",
                "sts:*"
            ],
            "Resource": "*",
            "Condition": {
                "StringNotEquals": {
                    "aws:RequestedRegion": [
                        "eu-west-1",
                        "eu-west-2",
                        "eu-central-1"
                    ]
                }
            }
        }
    ]
}
EOF
}