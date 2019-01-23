# Lab 4, Compliance reporting

## Overview
You have created a periodic reporting capability using CloudWatch scheduled events, you've created an automated remediation capability using CloudWatch Events, now let's use AWS Config to track the history of resources, and report on when resources have been compliant or not compliant with our policies.

In this lab you will create a custom Config Rule to periodically check all roles within your account and report back on whether they are compliant or non-compliant.  The Config service will then make this available as a report which can be monitored by the wider business or audit team.  Config will also show when roles have been compliant or  non-compliant and what changes occured to affect a role's status one way or the other.

## Steps
### By hand
#### Create the Config rule role
1. Sign into the AWS console and access the [IAM console](https://console.aws.amazon.com/iam/home)
1. From the left-hand menu click `Policies` and `Create policy`
1. Select the `JSON` tab and paste the contents of the [compliance_rule_policy.json](compliance_rule_policy.json) policy document
1. Click `Review policy` and give the new policy a unique name such as 'ComplianceRulePolicy-userA'
1. Click `Create policy`
1. From the left-hand menu click `Roles` and `Create role`
1. Select 'Lambda' as the service that will use the role and click `Next: Permissions`
1. Using the search field enter the first few characters of your new policy name.  Select its checkbox and click `Next: Tags`
1. Click `Next: Review` and give your role a unique name such as 'ComplianceRuleRole-userA'
1. Click `Create role`
#### Create the Lambda function
1. Access the [Lambda console](https://eu-west-1.console.aws.amazon.com/lambda/home)
1. Click `Create a function`
1. Give your function a unique name such as 'ComplianceFunc-userA'
1. From the drop down select the Python 3.6 runtime
1. From the role drop down select the role you created in the previous steps
1. Click `Create function`
1. On the resulting screen paste the code from [src/check_policy_enforcement.py](src/check_policy_enforcement.py) into the code editor for your Lambda function
1. Edit the line which defines the `policy_arn` variable to the ARN for the policy you created in Lab 1
```python
policy_arn = 'arn:aws:iam::012345678901:policy/ManagedPolicy'
```
9. Set the `Handler` field to `lambda_function.handler`
1. Set the function `Timeout` to 45 seconds
1. Click `Save`
#### Define the Config Rule
1. Access the [Config console]()
1. From the left-hand menu click `Rules`
1. Click `Add rule` and then click `Add custom rule`
1. Give your rule a unique name such as 'ComplianceRule-userA'
1. Paste the ARN of the Lambda function from the previous step into `AWS Lambda function ARN`
1. Select `Periodic` for the Trigger type
1. Set the frequency to `24 hours`
1. Click `Save`

### Using Terraform
