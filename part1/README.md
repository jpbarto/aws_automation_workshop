# AWS Automation - Part 1

## Overview
In this lab you will create an IAM policy using Terraform.  Then you will run a Python script to call the AWS APIs and list all roles that do not have the policy assigned to it.

## Steps
1. Push a managed IAM policy into your AWS account using Terraform

```bash
$ terraform init
$ terraform plan
$ terraform apply
```
1. Generate a report of roles that do not have the managed policy associated with it.  This will list all roles.

```Bash
$ python report_entities.py
```

1. Now, via the AWS console, associate the IAM policy with one or more roles and re-run the report.  The list should now reflect your changes.