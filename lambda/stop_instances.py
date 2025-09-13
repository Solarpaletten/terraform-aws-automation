import boto3
import json
import os

def handler(event, context):
    """
    Lambda function to stop EC2 instances with specific tags
    """
    
    # Initialize EC2 client
    ec2 = boto3.client('ec2', region_name=os.environ.get('REGION', 'eu-central-1'))
    
    project_name = "${project_name}"
    
    try:
        # Find instances to stop
        response = ec2.describe_instances(
            Filters=[
                {
                    'Name': 'tag:Name',
                    'Values': [f'{project_name}-auto-server']
                },
                {
                    'Name': 'tag:AutoStop',
                    'Values': ['true']
                },
                {
                    'Name': 'instance-state-name',
                    'Values': ['running']
                }
            ]
        )
        
        instances_to_stop = []
        
        # Extract instance IDs
        for reservation in response['Reservations']:
            for instance in reservation['Instances']:
                instances_to_stop.append(instance['InstanceId'])
        
        if instances_to_stop:
            # Stop the instances
            stop_response = ec2.stop_instances(InstanceIds=instances_to_stop)
            
            print(f"Stopping instances: {instances_to_stop}")
            
            return {
                'statusCode': 200,
                'body': json.dumps({
                    'message': f'Successfully stopped {len(instances_to_stop)} instances',
                    'instances': instances_to_stop,
                    'stopping_instances': stop_response.get('StoppingInstances', [])
                })
            }
        else:
            print("No running instances found to stop")
            return {
                'statusCode': 200,
                'body': json.dumps({
                    'message': 'No running instances found to stop',
                    'instances': []
                })
            }
            
    except Exception as e:
        print(f"Error stopping instances: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': f'Error stopping instances: {str(e)}'
            })
        }