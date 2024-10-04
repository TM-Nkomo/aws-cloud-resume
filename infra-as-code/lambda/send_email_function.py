import json
import boto3
from botocore.exceptions import ClientError

def lambda_handler(event, context):
    # Extract data from the event object
    body = json.loads(event['body'])
    name = body['name']
    email = body['email']
    message = body['message']
    
    # Create an SES client
    ses_client = boto3.client('ses', region_name='eu-north-1')

    # Compose the email
    subject = f"New message from {name}"
    body = f"Name: {name}\nEmail: {email}\nMessage:\n{message}"

    try:
        response = ses_client.send_email(
            Source='michellenkomo@outlook.com', 
            Destination={
                'ToAddresses': [
                    'michellenkomo@outlook.com',
                ]
            },
            Message={
                'Subject': {
                    'Data': subject,
                    'Charset': 'UTF-8'
                },
                'Body': {
                    'Text': {
                        'Data': body,
                        'Charset': 'UTF-8'
                    }
                }
            }
        )
        return {
            'statusCode': 200,
            'body': json.dumps('Email sent successfully!')
        }
    except ClientError as e:
        return {
            'statusCode': 500,
            'body': json.dumps(f"Failed to send email: {e.response['Error']['Message']}")
        }
