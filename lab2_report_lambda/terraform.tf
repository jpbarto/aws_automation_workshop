provider "aws" {
  region = "eu-west-1"
}

variable "stack_id" {
  default = "userA"
}

resource "aws_sns_topic" "entity_report_topic" {
  name = "entity-report-topic-${var.stack_id}"
}

output "SNS Topic Name" {
  value = "${aws_sns_topic.entity_report_topic.name}"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "src"
  output_path = "lambda.zip"
}

resource "aws_lambda_function" "entity_report_function" {
  filename         = "lambda.zip"
  source_code_hash = "${data.archive_file.lambda_zip.output_base64sha256}"
  function_name    = "EntityComplianceReport-${var.stack_id}"
  role             = "${aws_iam_role.entity_report_role.arn}"
  description      = "Check that all roles have managed IAM policies applied."
  handler          = "report_entities.handler"
  runtime          = "python3.6"
  timeout          = 60

  environment = {
    variables = {
      topic_arn = "${aws_sns_topic.entity_report_topic.arn}"
    }
  }
}

output "Lambda Function Name" {
  value = "${aws_lambda_function.entity_report_function.arn}"
}

resource "aws_iam_role" "entity_report_role" {
  name = "EntityComplianceReportRole-${var.stack_id}"

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
  name       = "EntityComplianceReportPolicy-${var.stack_id}"
  role       = "${aws_iam_role.entity_report_role.name}"
  depends_on = ["aws_iam_role.entity_report_role"]

  lifecycle {
    create_before_destroy = true
  }

  policy = "${file("reporter_policy.json")}"
}

resource "aws_cloudwatch_event_rule" "run_entity_compliance_report" {
  name                = "RunEntityComplianceReport-${var.stack_id}"
  description         = "Report nightly on entity compliance"
  schedule_expression = "cron(0 2 * * ? *)"
}

output "CloudWatch Event Rule" {
  value = "${aws_cloudwatch_event_rule.run_entity_compliance_report.name}"
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule = "${aws_cloudwatch_event_rule.run_entity_compliance_report.name}"
  arn  = "${aws_lambda_function.entity_report_function.arn}"
}
