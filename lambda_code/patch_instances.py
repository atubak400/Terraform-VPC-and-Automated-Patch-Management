import boto3

def lambda_handler(event, context):
    ec2 = boto3.client('ec2')
    ssm = boto3.client('ssm')

    # Find instances with tag "Patch" = "True"
    instances = ec2.describe_instances(
        Filters=[
            {
                'Name': 'tag:Patch',
                'Values': ['True']
            },
            {
                'Name': 'instance-state-name',
                'Values': ['running']
            }
        ]
    )

    instance_ids = []
    for reservation in instances['Reservations']:
        for instance in reservation['Instances']:
            instance_ids.append(instance['InstanceId'])

    if instance_ids:
        # Send patch command
        response = ssm.send_command(
            InstanceIds=instance_ids,
            DocumentName="AWS-RunPatchBaseline",
            Comment="Patching instances via Lambda",
            Parameters={"Operation": ["Install"]},
        )
        return {"message": "Patching started", "response": response}
    else:
        return {"message": "No instances found for patching"}
