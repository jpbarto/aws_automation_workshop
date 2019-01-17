import boto3

iam = boto3.client ('iam')
policy_arn = 'arn:aws:iam::776347453069:policy/ManagedPolicy'

print ("Searching for entities that do NOT have the following policy attached:")
print (policy_arn)

def get_roles (marker = None):
    roles = []
    if marker is None:
        roles_resp = iam.list_roles (PathPrefix = '/', MaxItems = 100)
    else:
        roles_resp = iam.list_roles (PathPrefix = '/', MaxItems = 100, Marker = marker)
        marker = None

    for role in roles_resp['Roles']:
        roles.append (role['RoleName'])

    if 'IsTruncated' in roles_resp and roles_resp['IsTruncated']:
        marker = roles_resp['Marker']

    return (roles, marker)

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

print ("List roles without policy attached")
(iam_roles, marker) = get_roles ()
while marker is not None:
    (roles, marker) = get_roles (marker = marker)
    iam_roles += roles
print ("Checking {} roles".format (len(iam_roles)))

for rolename in iam_roles:
    (role_policies, marker) = get_role_policies (rolename)
    while marker is not None:
        (policies, marker) = get_role_policies (rolename, marker = marker)
        role_policies += policies

    if policy_arn in role_policies:
        print ("User {} is compliant".format (rolename))
    else:
        print ("Role {} is NOT compliant".format (rolename))
