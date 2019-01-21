provider "aws" {
    region = "us-east-1"
}

resource "aws_iam_policy" "region_restriction_policy" {
  name       = "RegionRestrictionPolicy"

  lifecycle {
    create_before_destroy = true
  }

  policy = "${file("managed_policy.json")}"
}