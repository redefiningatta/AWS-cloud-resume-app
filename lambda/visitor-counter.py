import json
import boto3
import logging

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('cloud-resume-backend-VisitorCount')  # Your DynamoDB table name

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    try:
        response = table.get_item(Key={'id': 'visitorCount'})
        if 'Item' not in response:
            # Item does not exist, create it
            table.put_item(Item={'id': 'visitorCount', 'count': 0})
            visitor_count = 0
        else:
            visitor_count = response['Item']['count']
        
        # Convert visitor_count from Decimal to int
        visitor_count = int(visitor_count)
        
        # Increment the visitor count
        new_count = visitor_count + 1
        
        # Update the visitor count in DynamoDB
        table.update_item(
            Key={'id': 'visitorCount'},
            UpdateExpression='SET #c = :new_count',
            ExpressionAttributeNames={'#c': 'count'},
            ExpressionAttributeValues={':new_count': new_count}
        )
        
        logger.info(f"Visitor count updated to: {new_count}")

        # Return the updated visitor count
        return {
            'statusCode': 200,
            'body': json.dumps({'visitorCount': new_count}),
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': 'https://resume.iamatta.com'
            }
        }
    except Exception as e:
        logger.error(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'Could not update visitor count'}),
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': 'https://resume.iamatta.com'
            }
        }

