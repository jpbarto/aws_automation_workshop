# Automation lab

The purpose of this collection of lab material is to walk attendees through creating a Lambda function and having it execute periodically using CloudWatch Scheduled Events, respond in real time to CloudWatch Events, and later to be invoked by AWS Config.  As bonus Terraform will also be used to push the code into every region of one or more AWS accounts as a way to begin to manage multiple AWS accounts at scale using Terraform.

## Context
The customer would like to ensure that their employees only use approved regions.  To govern this the customer has created an IAM policy which must be attached to all users, groups, and roles in the account.  So they create a Python script to report any users, groups, or roles that do not have this managed policy attached.  Later the customer wants this script to be run automatically and to notify the user nightly.  The customer creates the script as a Lambda function and adds SNS notification as a way of subscribing to the findings.  The Lambda is scheduled to execute using CloudWatch scheduled events.  Eventually the customer gets tired of receiving nightly emails with a list of who is or is not compliant.  So they take an extra step to begin enforcing compliance.  The customer makes a similar lambda function which identifies non-compliant users, roles, or groups, and attaches the policy to the resource.  Using CloudWatch events the customer triggers the Lambda function whenever a user, role, or group is created.  Finally the customer decides to adopt AWS Config and so modifies the Lambda a 3rd time to be invoked by AWS Config and report any non-compliant resources.

As a final wrap up a Terraform template is maintained at each stage to deploy the functions and triggers necessary to script deployment of the resources at each stage.
