# AWS Automation - Part 1

## Overview
In this lab you will create an IAM policy using Terraform.  Then you will run a Python script to call the AWS APIs and list all roles that do not have the policy assigned to it.

## Steps
### By hand
1. Sign into the AWS console and access the `IAM` console
1. Click `Policies` from the left-hand menu
1. Click `Create policy`
1. Select the `JSON` tab and enter the contents of the [managed_policy.json](managed_policy.json) file
1. Click `Review policy`
1. Give the policy a unique name, such as 'user9-managed-policy'
1. Click `Create policy`
1. Follow the link to the policy in the next screen and take note of the Policy ARN of the policy.
1. Paste the ARN value into the [report_entities.py](report_entites.py) script at the line:
```Python
policy_arn = 'arn:aws:iam::012345678901:policy/YOUR-POLICY-NAME'
```
1. Now with the script configured to look for your policy ARN execute the script from the terminal
```Bash
$ python report_entities.py
```

> Note: notice the script should report that **ALL** roles are not compliant.  To make them compliant feel free to attach your new policy to some of the roles and re-run the script.

### Using Terraform
1. Push a managed IAM policy into your AWS account using Terraform

```Bash
$ terraform init
$ terraform plan
$ terraform apply
```
1. Generate a report of roles that do not have the managed policy associated with it.  This will list all roles.

```Bash
$ python report_entities.py
```

1. Now, via the AWS console, associate the IAM policy with one or more roles and re-run the report.  The list should now reflect your changes.