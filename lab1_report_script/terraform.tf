provider "aws" {
    region = "us-east-1"
}

variable "stack_id" {
  default = "u9"
}

resource "aws_iam_policy" "region_restriction_policy" {
  name       = "RegionRestrictionPolicy-${var.stack_id}"

  lifecycle {
    create_before_destroy = true
  }

  policy = "${file("managed_policy.json")}"
}

output "Managed Policy ARN" {
  value = "${aws_iam_policy.region_restriction_policy.arn}"
}
