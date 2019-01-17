import boto3
from datetime import datetime
import json

cfg = boto3.client ('config')
iam = boto3.client ('iam')

COMPLIANCE_STATES = {
    'COMPLIANT': 'COMPLIANT',
    'NON_COMPLIANT': 'NON_COMPLIANT',
    'NOT_APPLICABLE': 'NOT_APPLICABLE'
    }
policy_arn = 'arn:aws:iam::776347453069:policy/ManagedPolicy'

# Checks whether the invoking event is ScheduledNotification
def is_scheduled (event):
    return (event['messageType'] == 'ScheduledNotification')
    
def get_user_policies (username, marker = None):
    policies = []
    if marker is None:
        policy_resp = iam.list_attached_user_policies (UserName = username, MaxItems = 100)
    else:
        policy_resp = iam.list_attached_user_policies (UserName = username, MaxItems = 100, Marker = marker)
        marker = None

    for policy in policy_resp['AttachedPolicies']:
        policies.append (policy['PolicyArn'])

    if 'IsTruncated' in policy_resp and policy_resp['IsTruncated']:
        marker = policy_resp['Marker']

    return (policies, marker)
    
def get_role_policies (rolename, marker = None):
    policies = []
    if marker is None:
        policy_resp = iam.list_attached_role_policies (RoleName = rolename, MaxItems = 100)
    else:
        policy_resp = iam.list_attached_role_policies (RoleName = rolename, MaxItems = 100, Marker = marker)
        marker = None

    for policy in policy_resp['AttachedPolicies']:
        policies.append (policy['PolicyArn'])

    if 'IsTruncated' in policy_resp and policy_resp['IsTruncated']:
        marker = policy_resp['Marker']

    return (policies, marker)

# Evaluates the configuration items in the snapshot and returns the compliance value to the handler.
def evaluate_user (username):
    user_policies = []
    
    (user_policies, marker) = get_user_policies (username)
    while marker is not None:
        (policies, marker) = get_user_policies (username, marker = marker)
        user_policies += policies

    if policy_arn in user_policies:
        return COMPLIANCE_STATES['COMPLIANT']
            
    return COMPLIANCE_STATES['NON_COMPLIANT']
    
def evaluate_role (rolename):
    role_policies = []
    
    (role_policies, marker) = get_role_policies (rolename)
    while marker is not None:
        (policies, marker) = get_role_policies (rolename, marker = marker)
        role_policies += policies

    if policy_arn in role_policies:
        return COMPLIANCE_STATES['COMPLIANT']
            
    return COMPLIANCE_STATES['NON_COMPLIANT']

def get_users ():
    token = None
    resources = []
    
    (rsrcs, token) = get_resources ('AWS::IAM::User', next_token = token)
    resources += rsrcs
    
    while token is not None:
        (rsrcs, token) = get_resources ('AWS::IAM::User', next_token = token)
        resources += rsrcs
        
    return resources
    
def get_roles ():
    token = None
    resources = []
    
    (rsrcs, token) = get_resources ('AWS::IAM::Role', next_token = token)
    resources += rsrcs
    
    while token is not None:
        (rsrcs, token) = get_resources ('AWS::IAM::Role', next_token = token)
        resources += rsrcs
    
    return resources

def get_resources (rsrc_type, next_token):
    if next_token is not None:
        resp = cfg.list_discovered_resources (
            resourceType = rsrc_type,
            includeDeletedResources = False,
            nextToken = next_token
            )
    else:
        resp = cfg.list_discovered_resources (
            resourceType = rsrc_type,
            includeDeletedResources = False
            )
        
    rsrcs = resp['resourceIdentifiers']
    next_token = None
    if 'nextToken' in resp:
        next_token = resp['nextToken']
        
    return (rsrcs, next_token)


# Receives the event and context from AWS Lambda. You can copy this handler and use it in your own
# code with little or no change.
def handler (event, context):
    print ("Processing event: {}".format (event))

    return_message = 'Invoked for a notification other than Scheduled Notification... Ignoring.'
    
    invoking_event = json.loads (event['invokingEvent'])
    rule_parameters = {}
    if 'ruleParameters' in event:
        rule_parameters = json.loads (event['ruleParameters'])
    result_token = event['resultToken']

    if (is_scheduled (invoking_event)):
        evaluations = []
        eval_time = datetime.now ()
        
        users = get_users ()
        for user in users:
            compliance = evaluate_user (user['resourceName'])
            evaluations.append ({
                'ComplianceResourceType': user['resourceType'],
                'ComplianceResourceId': user['resourceId'],
                'ComplianceType': compliance,
                'OrderingTimestamp': eval_time
            })
            
        roles = get_roles ()
        for role in roles:
            compliance = evaluate_role (role['resourceName'])
            evaluations.append ({
                'ComplianceResourceType': role['resourceType'],
                'ComplianceResourceId': role['resourceId'],
                'ComplianceType': compliance,
                'OrderingTimestamp': eval_time
            })
        
        for i in range(0,len(evaluations),50):
            cfg.put_evaluations (
                Evaluations = evaluations[i:(i+50)],
                ResultToken = result_token
                )
        
        return_message = "Evaluationed {} users and {} roles".format (len(users), len(roles))

    print (return_message)
    return return_message
