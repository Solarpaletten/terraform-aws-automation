import boto3
import json
import os

def handler(event, context):
    """
    Lambda function to start EC2 instances with specific tags
    """
    
    # Initialize EC2 client
    ec2 = boto3.client('ec2', region_name=os.environ.get('REGION', 'eu-central-1'))
    
    project_name = "${project_name}"
    
    try:
        # Find instances to start
        response = ec2.describe_instances(
            Filters=[
                {
                    'Name': 'tag:Name',
                    'Values': [f'{project_name}-auto-server']
                },
                {
                    'Name': 'tag:AutoStart',
                    'Values': ['true']
                },
                {
                    'Name': 'instance-state-name',
                    'Values': ['stopped']
                }
            ]
        )
        
        instances_to_start = []
        
        # Extract instance IDs
        for reservation in response['Reservations']:
            for instance in reservation['Instances']:
                instances_to_start.append(instance['InstanceId'])
        
        if instances_to_start:
            # Start the instances
            start_response = ec2.start_instances(InstanceIds=instances_to_start)
            
            print(f"Starting instances: {instances_to_start}")
            
            return {
                'statusCode': 200,
                'body': json.dumps({
                    'message': f'Successfully started {len(instances_to_start)} instances',
                    'instances': instances_to_start,
                    'starting_instances': start_response.get('StartingInstances', [])
                })
            }
        else:
            print("No stopped instances found to start")
            return {
                'statusCode': 200,
                'body': json.dumps({
                    'message': 'No stopped instances found to start',
                    'instances': []
                })
            }
            
    except Exception as e:
        print(f"Error starting instances: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': f'Error starting instances: {str(e)}'
            })
        }