provider "aws" {
    region = "us-east-1"
}

data "archive_file" "lambda_zip" {
    type        = "zip"
    source_dir  = "src"
    output_path = "lambda.zip"
}

resource "aws_lambda_function" "enforce_compliance_function" {
  filename = "lambda.zip"
  source_code_hash = "${data.archive_file.lambda_zip.output_base64sha256}"
  function_name = "PolicyEnforcementFunction"
  role = "${aws_iam_role.policy_enforcement_role.arn}"
  description = "Attach managed policies to roles upon creation."
  handler = "remediate_entities.handler"
  runtime = "python3.6"
  timeout = 60
}

resource "aws_iam_role" "policy_enforcement_role" {
  name = "PolicyEnforcementRole"

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

resource "aws_iam_role_policy" "enforcement_policy" {
  name       = "PolicyEnforcementPolicy"
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
                "iam:ListAttachedRolePolicies",
                "iam:AttachRolePolicy"
            ],
            "Resource": "arn:aws:iam::*:role/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "iam:ListRoles",
                "logs:CreateLogGroup",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_cloudwatch_event_rule" "assign_policy" {
  name        = "PolicyEnforcementRule"
  description = "Execute compliance rule when a role is created."
  event_pattern = <<PATTERN
{
  "source": [
    "aws.iam"
  ],
  "detail-type": [
    "AWS API Call via CloudTrail"
  ],
  "detail": {
    "eventSource": [
      "iam.amazonaws.com"
    ],
    "eventName": [
      "CreateRole"
    ]
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule      = "${aws_cloudwatch_event_rule.assign_policy.name}"
  arn       = "${aws_lambda_function.enforce_compliance_function.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.enforce_compliance_function.function_name}"
  principal     = "events.amazonaws.com"
  source_arn = "${aws_cloudwatch_event_rule.assign_policy.arn}"
}