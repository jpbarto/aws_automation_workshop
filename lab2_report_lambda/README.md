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