# AWS Automation Workshop

The purpose of this collection of lab material is to walk readers through creating a Lambda function and having it execute periodically using CloudWatch Scheduled Events, respond in real time to CloudWatch Events, and later to be invoked by AWS Config.  In addition the manual step-by-step guidance, Terraform scripts are also provided to demonstrate how to use infrastructure as code.

## Context
The customer would like to ensure that their employees only use approved regions.  To govern this the customer has created an IAM policy which must be attached to all users, groups, and roles in the account.  So they create a Python script to report any users, groups, or roles that do not have this managed policy attached.  Later the customer wants this script to be run automatically and to notify the user nightly.  The customer creates the script as a Lambda function and adds SNS notification as a way of subscribing to the findings.  The Lambda is scheduled to execute using CloudWatch scheduled events.  Eventually the customer gets tired of receiving nightly emails with a list of who is or is not compliant.  So they take an extra step to begin enforcing compliance.  The customer makes a similar Lambda function which identifies non-compliant users, roles, or groups, and attaches the policy to the resource.  Using CloudWatch events the customer triggers the Lambda function whenever a user, role, or group is created.  Finally the customer decides to adopt AWS Config and so modifies the Lambda a 3rd time to be invoked by AWS Config and report any non-compliant resources.

As a final wrap up a Terraform template is maintained at each stage to deploy the functions and triggers necessary to script deployment of the resources at each stage.

> Note that for simplicity all code only checks and remediates roles.  The code to check users and groups is very similar and is left to the reader to implement.

## Stages

### [Lab 1, Reporting Script](lab1_report_script)
1. Create a managed policy in IAM to enforce approved regions
1. Review a Python script to produce a report of compliant entities in your AWS account
1. How would you modify the script to report on multiple accounts and / or regions?

### [Lab 2, Nightly Reporting Lambda](lab2_report_lambda)
1. Convert the script to be a lambda function and add SNS notification
1. Configure CloudWatch events to execute the Lambda function every night

### [Lab 3, Autoremediating Resources](lab3_compliance_enforcement)
1. Rewrite the Lambda function to remediate any non-compliant entities
1. Trigger the Lambda function in response to role creation using CloudWatch events

### [Lab 4, Continually Verify Resources](lab4_compliance_report)
1. Rewrite the Lambda function to operate as a Config Rule
1. Create the config rule to determine compliant and non-compliant entities

## Getting started (Only needed to have access to a Python interpreter and Terraform)
1. To get started sign into the AWS console and visit the [Cloud9 console](https://eu-west-1.console.aws.amazon.com/cloud9/home?region=eu-west-1#)
1. Click `Launch IDE` from the console.
1. When the IDE opens click in the Terminal on the lower half of the IDE.  Execute the following:
```bash
$ wget https://releases.hashicorp.com/terraform/0.11.11/terraform_0.11.11_linux_amd64.zip
$ unzip terraform_0.11.11_linux_amd64.zip 
$ sudo mv terraform /usr/local/bin
$ terraform -h
```

Now move on to [Lab 1](lab1_report_script).
