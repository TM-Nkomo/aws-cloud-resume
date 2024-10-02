import json
import boto3

dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
table = dynamodb.Table('cloud-resume-test')

def lambda_handler(event, context):
    # get views
    response = table.get_item(Key={
        'id': '1'
    })
    
    # increment and display views
    views = response['Item']['views']
    views += 1
    print(views)
    
    # update database
    response = table.put_item(Item = {
        'id': '1',
        'views': views
    })
    
    return views