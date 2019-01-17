import boto3

policy_arn = 'arn:aws:iam::776347453069:policy/ManagedPolicy'

iam = boto3.client ('iam')

def remediate_role (rolename):
    iam.attach_role_policy (RoleName = rolename, PolicyArn = policy_arn)
    return True

def handler (event, context):
    print ("Processing event: {}".format (event))
    
    event_detail = {}
    if 'detail' in event:
        event_detail = event['detail']

    report = {
        'Enforced': False
    }

    if 'eventName' in event_detail:
        print ("Processing event {}".format (event_detail['eventName']))
        
    if 'eventName' in event_detail and event_detail['eventName'] == 'CreateRole':
        rolename = event_detail['requestParameters']['roleName']
        report['RoleName'] = rolename
        report['Enforced'] = remediate_role (rolename)
    else:
        report['Reason'] = 'No role creation found'
        
    print (report)

    return report