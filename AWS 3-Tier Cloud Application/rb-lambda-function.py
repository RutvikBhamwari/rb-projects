import json
import boto3

def lambda_handler(event, context):
    # TODO implement
    sqs = boto3.resource('sqs')
    #GET QUEUE URL
    queue = sqs.get_queue_by_name(QueueName='rb-queue')
    queueurl = queue.url
    print(queue.url)
    
    # Process messages by printing out body and optional author name
    for message in queue.receive_messages(MessageAttributeNames=['Title']):
    # Get the custom author message attribute if it was set
        author_text = ''
        if message.message_attributes is not None:
            author_name = message.message_attributes.get('Title').get('StringValue')
            if author_name:
                author_text = '{0}'.format(author_name)
   
        print('Hello,{0}!{1}'.format(message.body, author_text))
        uuid = '{0}'.format(message.body, author_text)
        #print('{0}'.format(message.body))
        print(uuid)
        uemail = '{1}'.format(message.body, author_text)
        print(uemail)
    # Let the queue know that the message is processed
        #message.delete()
    #print(uuid)
    
    #CONNECTING TO DYNAMODB CLIENT
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('Records-rb')
    # https://boto3.amazonaws.com/v1/documentation/api/latest/guide/dynamodb.html#getting-an-item

    #GETTING ITEM AS PER RECEIPT
    response = table.get_item(
        Key={
            'Receipt': uuid,
            'Email': uemail
        }
    )
    print(response)
    phone = response['Item']['Phone']
    print(phone)
    item = response['Item']['Filename']
    print(item)
    s3 = boto3.client('s3')
    test_path = '/tmp/output'
    s3.download_file('rb-raw-bucket',item,test_path)
    s3.upload_file(test_path,'rb-finished-bucket',item, ExtraArgs={'ACL': 'public-read'})
    bucket_location = s3.get_bucket_location(Bucket='rb-finished-bucket')
    #print(bucket_location)
    gurl = 'https://%s.s3.amazonaws.com/%s' % ('rb-finished-bucket', item)
    print(gurl)
    table.update_item(
        Key={
            'Receipt': uuid,
            'Email': uemail
        },
        UpdateExpression='SET S3finishedurl = :val1 ',#, Issubscribed = :val2 , Status = :val3',
        ExpressionAttributeValues={
            ':val1': gurl
            #':val2': True,
        },
    )
    #SENDING SNS NOTIFICATION
    client = boto3.client('sns')
    
    #SENDING THE MESSAGE
    response = client.publish(
        PhoneNumber=phone,
        Message='Your link image is rendered:'+gurl,
        #Subject='MP2 Image Conversion App'
    )
    print(response)
    message.delete()
    return{
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }