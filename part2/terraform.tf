provider "aws" {
    region = "us-east-1"
}

resource "aws_sns_topic" "entity_report_topic" {
  name = "entity-report-topic"
}

data "archive_file" "lambda_zip" {
    type        = "zip"
    source_dir  = "src"
    output_path = "lambda.zip"
}

resource "aws_lambda_function" "entity_report_function" {
  filename = "lambda.zip"
  source_code_hash = "${data.archive_file.lambda_zip.output_base64sha256}"
  function_name = "EntityComplianceReport"
  role = "${aws_iam_role.entity_report_role.arn}"
  description = "Check that all roles have managed IAM policies applied."
  handler = "report_entities.handler"
  runtime = "python3.6"
  timeout = 60
  environment = {
      variables = {
          topic_arn = "${aws_sns_topic.entity_report_topic.arn}"
      }
  }
}

resource "aws_iam_role" "entity_report_role" {
  name = "EntityComplianceReportRole"

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

resource "aws_iam_role_policy" "entity_report_policy" {
  name       = "EntityComplianceReportPolicy"
  role       = "${aws_iam_role.entity_report_role.name}"
  depends_on = ["aws_iam_role.entity_report_role"]

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
                "sns:Publish",
                "iam:ListAttachedRolePolicies",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:*:*:log-group:*",
                "arn:aws:iam::*:role/*",
                "arn:aws:sns:*:*:*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "config:ListDiscoveredResources",
                "iam:ListRoles",
                "config:PutEvaluations",
                "logs:CreateLogGroup"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "logs:PutLogEvents",
            "Resource": "arn:aws:logs:*:*:log-group:*:*:*"
        }
    ]
}
EOF
}
