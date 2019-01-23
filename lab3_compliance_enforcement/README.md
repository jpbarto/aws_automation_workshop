# Lab 3: Automate compliance with real-time correction

## Overview
Getting a report after as much as 24 hours after a role has been created is only effective after 24 hours.  In the meantime a role can operate without being in compliance with your policies.  To enforce that all resources in your AWS account are inline with your policies lets use CloudWatch Events and Lambda to inspect any roles upon creation.  If the new role does not have your policy associated with it, attach it.

> Please note this lab MUST BE CONDUCTED IN US-EAST-1.  CloudWatch Events for IAM are tracked in US-East-1 so for this lab please carry out the below steps in the N. Virginia region.

## Steps
### By hand
#### Enforcement permissions
1. Sign into the AWS console and access the [IAM console](https://console.aws.amazon.com/iam/home)
1. From the left-hand menu click `Policies` and `Create policy`
1. Select the `JSON` tab and paste the contents of the [enforcer_policy.json](enforcer_policy.json) policy document
1. Click `Review policy` and give the new policy a unique name such as 'EnforcementPolicy-userA'
1. Click `Create policy`
1. From the left-hand menu click `Roles` and `Create role`
1. Select 'Lambda' as the service that will use the role and click `Next: Permissions`
1. Using the search field enter the first few characters of your new policy name.  Select its checkbox and click `Next: Tags`
1. Click `Next: Review` and give your role a unique name such as 'EnforcementRole-userA'
1. Click `Create role`
#### Enforcement Lambda function
1. Access the [Lambda console](https://eu-west-1.console.aws.amazon.com/lambda/home)
1. Click `Create a function`
1. Give your function a unique name such as 'EnforcementFunc-userA'
1. from the drop down select the Python 3.6 runtime
1. From the role drop down select the role you created in the previous steps
1. Click `Create function`
1. On the resulting screen paste the code from [src/remediate_entities.py](src/remediate_entities.py) into the code editor for your Lambda function
1. Edit the line which defines the `policy_arn` variable to the ARN for the policy you created in Lab 1
```python
policy_arn = 'arn:aws:iam::012345678901:policy/ManagedPolicy'
```
1. Set the `Handler` field to `lambda_function.handler`
1. Set the function `Timeout` to 45 seconds
1. Click `Save`
#### Configure CloudWatch Events
1. Access the [CloudWatch console](https://eu-west-1.console.aws.amazon.com/cloudwatch/home)
1. On the left, under `Events` click `Rules`
1. Click `Create rule`
1. Under `Event pattern` for `Service Name` select `IAM` from the drop down
1. From the drop down for `Event Type` select `AWS API Call via CloudTrail`
1. Next select the radio button for `Specific operations` and enter a value of `CreateRole` in the input field
1. Under `Target` select `Add target`
1. From the `Function` drop down select your Lambda function and click `Configure details`
1. Give your rule a unique name such as 'EnforcementRule-userA' and click `Create rule`


## Test your rule
1. From the [IAM console](https://console.aws.amazon.com/iam/home) click `Roles`
1. Click `Create role` and select `Lambda` as the service that will use the role
1. Click `Next: Permissions`
1. Click `Next: Tags`
1. Click `Next: Review` and give your role a unique name like 'TestRole-userA'
1. Click `Create role`
1. On the next screen click the link for your newly created role
1. After a few minutes the role should be updated with your managed policy attached to it.