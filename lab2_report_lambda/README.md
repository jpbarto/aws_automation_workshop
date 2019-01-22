# Lab 2: Create a reporting Lambda

Having a script to produce a report of entities which are non-compliant is great but requires manually running the report regularly.  Instead lets have AWS periodically execute this report for us and issue an email nightly.  To do this we will use a CloudWatch scheduled event to execute an AWS Lambda function and send the results to an SNS topic.  

To do this we will create the scheduled event using Cron notation, modify the Python code from the previous lab to become a Lambda function, and add an SNS notification so we can subscribe to the report.

## Steps
### By hand
#### Create an IAM role
1. Sign into the AWS console and head to the [IAM console](https://console.aws.amazon.com/iam/home)
1. Select `Roles` from the left-hand menu and click `Create role`
1. From the list of AWS services on the next page select `Lambda` and click `Next: Permissions`
1. Without selecting any policies click `Next: Tags` and then click `Next: Review`
1. Give your role a unique name such as 'U9ReporterRole' and click `Create role`
1. Click the link which is presented for your new role and on the `Permissions` tab click `Add inline policy`
1. Select the 'JSON' tab and enter the contents of the [reporter_policy.json](reporter_policy.json) file
1. Click `Review policy` and give the policy a unique name such as 'U9ReporterPolicy'
#### Create an SNS topic
1. Go to the [SNS console](https://eu-west-1.console.aws.amazon.com/sns/v2/home)
1. Click `Create topic`
1. Give the topic a unique name such as 'U9ReporterTopic' and a display name such as 'U9Reporter'
1. Click `Create topic`
1. Make a note of the topic ARN for use later, something such as `arn:aws:sns:us-east-1:012345678901:U9ReporterTopic`
1. Create a subscription to the topic so that you receive an email when your report is published to the topic.  Click `Create subscription`
1. From the `Protocol` drop down select `Email`
1. Enter your email address as the value for `Endpoint` and click `Create subscription`
1. After a moment you should receive a confirmation email, open the email and click the `Confirm subscription` link.  This email address will now receive messages published to the SNS topic
#### Create the Lambda function
1. Click `Create policy`
1. Now go to the [Lambda console](https://eu-west-1.console.aws.amazon.com/lambda/home)
1. Click 'Create a function'
1. Select 'Author from scratch', give your function a name such as 'User09Reporter' and select the 'Python 3.6' runtime from the drop down.
1. From the drop down for 'Existing role' select the role you created in the previous steps.
1. Click `Create function`
1. On the resulting screen paste the contents of the modified Python script [src/report_entities.py](src/report_entities.py)
1. Paste the ARN of your managed policy into the Python code which defines the `policy_arn` variable:
```Python
policy_arn = 'arn:aws:iam::012345678901:policy/ManagedPolicy'
```
1. Set the `Handler` field to `lambda_function.handler`
1. Specify an `Environment variable` named `topic_arn` and paste the value of the ARN for the SNS topic created above into the value for the environment variable
1. Under `Basic settings` specify a Timeout value of 30 seconds
1. Click `Save` in the upper right of the Lambda console
1. Test the Lambda function by clicking `Test`
1. You will be asked to create an event to send to the Lambda function, accept the default, give it a name like `SimpleEvent` and click `Create`
1. Click the `Test` button again to execute the Lambda function with the new test event
> You should see the output of your function in the Lambda console.  If executed successfully you should also have an email in your inbox after a short period with a copy of the report generated.
#### CloudWatch Scheduled Event
1. Lets have CloudWatch automatically execute this report nightly.  Start by accessing the [CloudWatch console](https://eu-west-1.console.aws.amazon.com/cloudwatch/home)
1. On the left, under Events, click `Rules`
1. Click `Create rule`
1. For the `Event Source` select `Schedule`
1. Enter a `Cron expression` of `0 2 * * ? *` to generate the report every night at 02:00 AM
1. Next click `Add target`
1. From the `Function` drop down select your Lambda function
1. Click `Configure details`
1. Give your CloudWatch rule a unique name like 'U9PolicyReporter'
1. Click `Create rule`

### Using Terraform
1. Edit the Lambda function script to 
1. Edit the Lambda function script at [src/report_entities.py](src/report_entities.py) and paste the ARN of your managed policy into the Python code which defines the `policy_arn` variable:
```Python
policy_arn = 'arn:aws:iam::012345678901:policy/ManagedPolicy'
```
1. Now push the infrastructure for this lab into the AWS account using the following Terraform commands:
```bash
$ terraform init
$ terraform plan
$ terraform apply
```
#### Subscribe to the SNS topic
1. Go to the [SNS console](https://eu-west-1.console.aws.amazon.com/sns/v2/home)
1. Create a subscription to the topic so that you receive an email when your report is published to the topic.  Click `Create subscription`
1. From the `Protocol` drop down select `Email`
1. Enter your email address as the value for `Endpoint` and click `Create subscription`
1. After a moment you should receive a confirmation email, open the email and click the `Confirm subscription` link.  This email address will now receive messages published to the SNS topic
#### Test the Lambda function
1. Go to the [Lambda console](https://eu-west-1.console.aws.amazon.com/lambda/home)
1. Select the Lambda function that was created for you by Terraform
1. Test the Lambda function by clicking `Test`
1. You will be asked to create an event to send to the Lambda function, accept the default, give it a name like `SimpleEvent` and click `Create`
1. Click the `Test` button again to execute the Lambda function with the new test event
> You should see the output of your function in the Lambda console.  If executed successfully you should also have an email in your inbox after a short period with a copy of the report generated.

## Summary
In this lab you have converted your Python script to execute as a Lambda function.  CloudWatch will now execute this Lambda function every night and email a report to all persons who have subscribed to the SNS topic.  The business will now automatically receive updates about the compliance of roles within the account.