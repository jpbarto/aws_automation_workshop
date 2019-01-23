provider "aws" {
  region = "eu-west-1"
}

variable "stack_id" {
  default = "u9"
}

data "archive_file" "lambda_zip" {
    type        = "zip"
    source_dir  = "src"
    output_path = "lambda.zip"
}

resource "aws_lambda_function" "policy_enforcement_function" {
  filename = "lambda.zip"
  source_code_hash = "${data.archive_file.lambda_zip.output_base64sha256}"
  function_name = "PolicyEnforcementCheck-${var.stack_id}"
  role = "${aws_iam_role.policy_enforcement_role.arn}"
  description = "Check that all users and roles have managed IAM policies applied."
  handler = "check_policy_enforcement.handler"
  runtime = "python3.6"
  timeout = 60
}

resource "aws_iam_role" "policy_enforcement_role" {
  name = "PolicyEnforcementRole-${var.stack_id}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "policy_enforcement_policy" {
  name       = "PolicyEnforcementPolicy-${var.stack_id}"
  role       = "${aws_iam_role.policy_enforcement_role.name}"
  depends_on = ["aws_iam_role.policy_enforcement_role"]

  lifecycle {
    create_before_destroy = true
  }

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "iam:ListAttachedRolePolicies",
                "iam:ListAttachedUserPolicies",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:us-east-1:776347453069:log-group:*:*:*",
                "arn:aws:iam::*:user/*",
                "arn:aws:iam::*:role/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "config:ListDiscoveredResources",
                "config:PutEvaluations",
                "logs:CreateLogGroup"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}


resource "aws_config_config_rule" "enforce_policy_rule" {
  name = "EnforcePolicyRule-${var.stack_id}"

  source = {
    owner             = "CUSTOM_LAMBDA"
    source_identifier = "${aws_lambda_function.policy_enforcement_function.arn}"

    source_detail = {
      maximum_execution_frequency = "TwentyFour_Hours"
      message_type                = "ScheduledNotification"
    }
  }
}

resource "aws_lambda_permission" "allow_config" {
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.policy_enforcement_function.function_name}"
  principal     = "config.amazonaws.com"
}