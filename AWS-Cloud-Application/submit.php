<?php
// Start the session
session_start();
$imgloaded=$_POST['useremail'];
$phonenumber=$_POST['phone'];
echo $imgloaded;
$uploaddir = '/tmp/';
$uploadfile = $uploaddir.basename($_FILES['userfile']['name']);
echo '<pre>';

if (move_uploaded_file($_FILES['userfile']['tmp_name'], $uploadfile)) {
    echo "File is valid, and was successfully uploaded.\n";
} else {
    echo "Possible file upload attack!\n";
}
echo 'Here is some more debugging info:';
print_r($_FILES);
print "</pre>";
require '/home/ubuntu/vendor/autoload.php';

//Create a S3Client
use Aws\S3\S3Client;
$s3 = new Aws\S3\S3Client([
    'version' => 'latest',
    'region' => 'us-east-1'
]);

//Putting object in the raw bucket
$bucket="rb-raw-bucket";
$key = $_FILES['userfile']['name'];
$result = $s3->putObject([
    'ACL' => 'public-read',
    'Bucket' => $bucket,
    'Key' => $key,
    'SourceFile' => $uploadfile 
]);
$rawurl = $result['ObjectURL'];
echo "<br>";
echo nl2br("Raw Bucket link: ".$rawurl);

echo "----------------------------------------------------------Connecting DynamoDB-----------------------------------";


#CONNECTING TO DYNAMODB CLIENT
require '/home/ubuntu/vendor/autoload.php';
use Aws\DynamoDb\DynamoDbClient;
$clientdynamo = new DynamoDbClient([
    //'profile' => 'default',
    'region'  => 'us-east-1',
    'version' => 'latest'
]);

#GENERATING UUID
$receipt = uniqid(); 
echo "UUID:" . $receipt;

#PUTTING ITEM IN DYNAMODB WITH UNIQUE UUID
$result = $clientdynamo->putItem([
    'TableName' => "Records-rb", // REQUIRED
    'Item' => [ // REQUIRED
        'Receipt' => ['S' => $receipt],
        'Email' => ['S' => $imgloaded],
        'Phone' => ['S' => $phonenumber],
        'Filename' => ['S' => $key],
        'S3rawurl' => ['S' => $rawurl],
        'S3finishedurl' => ['S' => "NA"],     
        'Status' => ['BOOL' => true],
        'Issubscribed' => ['BOOL' => true]     
        ]   
    ]);
/*$result = $clientdynamo->putItem([
'TableName' => 'Records-rb', // REQUIRED
'Item' => [ // REQUIRED
    'Receipt' => ['S' => $receipt],
    'Email' => ['S' => $_POST['useremail']],
    'Phone' => ['S' => $_POST['phone']],
    'Filename' => ['S' => $uploadfile],
    'S3rawurl' => ['S' => $rawurl],
    'S3finishedurl' => ['S' => 'NA'],     
    'Status' => ['BOOL' => false],
    'Issubscribed' => ['BOOL' => false]     
    ],
]);*/
print_r($result);

echo "----------------------------------------------------------Item added in the DynamoDB-----------------------------------";


require '/home/ubuntu/vendor/autoload.php';
#CONNECTING TO THE SQS CLIENT
use Aws\Sqs\SqsClient;
$clientsqs = new SqsClient([
    //'profile' => 'default',
    'region'  => 'us-east-1',
    'version' => 'latest'
]);
echo "----------------------------------------------------------Connecting SQS-----------------------------------";

#GET THE QUEUE URL
$result = $clientsqs->getQueueUrl([
    'QueueName' => 'rb-queue', // REQUIRED
    //'QueueOwnerAWSAccountId' => '<string>',  // optional
]);
print_r($result['QueueUrl']);
$QURL = $result['QueueUrl'];
echo "URL: " . $QURL;

#SEND MESSAGE IN THE QUEUE

#$clientsqs = new SqsClient([
echo "-----------------------------------------------------till no woring------------------------";
echo "----------------------------------------------------------Sending SQS-----------------------------------";
$resultsqs = $clientsqs->sendMessage([
    'MessageAttributes' => [
        "Title" => [
            'DataType' => "String",
            'StringValue' => $imgloaded
        ]
    ],
    'MessageBody' => $receipt, // put UUID or receipt value here for look up. 
    'QueueUrl' => $QURL, // REQUIRED
]);
echo "the email is: ". $imgloaded;
echo "SQS sent to " . $QURL;
print_r($resultsqs);
/*
$message = [
    'id' => $receipt,
    'email' => $imgloaded
];
$messageResult = $clientsqs->sendMessage([
    'QueueUrl' => $QURL, 
    'MessageBody' => json_encode($message)
    ]);
*/

echo "----------------------------------------------------------UUID is added to the Queue-----------------------------------";

#CONNECTING LAMBDA ARN
require '/home/ubuntu/vendor/autoload.php';
use Aws\Lambda\LambdaClient;
$client = new LambdaClient([
    'region'  => 'us-east-1',
    'version' => 'latest'
]);

$result = $client->getFunction([
    'FunctionName' => 'rb-lambda-function', // REQUIRED
]);
$LambdaArn=$result['Configuration']['FunctionArn'];
print($LambdaArn);


#SEND SNS MESSAGE TO THE TOPIC
require '/home/ubuntu/vendor/autoload.php';

#CONNECTING TO THE SNS CLIENT
use Aws\Sns\SnsClient;
$client = new SnsClient([
    'region'  => 'us-east-1',
    'version' => 'latest'
]);

#LISTING THE SNS TOPICS
$result = $client->listTopics([
    // no need to call anything, as it will list all
 ]);
 print_r($result);
$TopicArn = $result['Topics'][0]['TopicArn'];
echo "\n" . $TopicArn . "\n";
/*
 #SUBSCRIBING LAMBDA FUNCTION TO THE TOPIC SELECTED
 $result = $client->subscribe([
    'Endpoint' => 'arn:aws:lambda:us-east-1:825586514029:function:my-python-pro-test',  // LAMBDA ARN
    'Protocol' => 'lambda', // REQUIRED
    'ReturnSubscriptionArn' => true,
    'TopicArn' => $TopicArn, // REQUIRED
]);*/

#SUBSCRIBING PHONE TO THE TOPIC SELECTED
$result = $client->subscribe([
    'Endpoint' => $phonenumber,  // LAMBDA ARN
    'Protocol' => 'sms', // REQUIRED
    'ReturnSubscriptionArn' => true,
    'TopicArn' => $TopicArn, // REQUIRED
]);
/*
$result = $clientdynamo->updateItem([
    'Key' => [
        'Receipt' => ['S' => $receipt],
        'Email' => ['S' => $imgloaded],
    ],
    'ExpressionAttributeNames' => [
        '#S' => "Status",
        '#SUB' => "Issubscribed",
    ],
    'ExpressionAttributeValues' => [
        ':s' => ['Status' => ['BOOL' => 'true']],
        ':i' => ['Issubscribed' => ['BOOL' => 'true']],
    ],
    'TableName' => 'Records-rb',
    'ReturnValues' => 'ALL_NEW',
    'UpdateExpression' => "SET #SUB = :i, SET #S = :s",
]);
*/
echo "lambda activating";

#PUBLISHING THE MESSAGE TO LAMBDA
$result = $client->publish([
    'Message' => 'Your image is being proccessed', // REQUIRED
    'TopicArn' => $TopicArn,
    'TargetARN' => $LambdaArn,  // LAMBDA ARN
    'Subject' => 'Submitted Image ready',
]);
echo "lambda activated";
######process hits in


#GET INFORAMTION ABOUT THE RAW URL AS PER UUID




#$tn = new Imagick($uploadfile);
#$tn->resizeImage(50,50,Imagick::FILTER_LANCZOS,1);
#$tn->writeImage();

/*$bucket1="rb-finished-bucket";
$resultmod = $s3->putObject([
    'ACL' => 'public-read',
    'Bucket' => $bucket1,
    'Key' => $key,
    'SourceFile' => $uploadfile
]);
$urlmod = $resultmod['ObjectURL'];
echo "<br>";
echo "<br>";
echo nl2br("Finshed Bucket link: ".$urlmod);

require '/home/ubuntu/vendor/autoload.php';
use Aws\Rds\RdsClient;
$rds = RdsClient::factory(array(
    'version' => 'latest',
    'region'  => 'us-east-1'));
$result = $rds->describeDBInstances(['DBInstanceIdentifier' == 'rb-instance']);
$endpoint = $result['DBInstances'][0]['Endpoint']['Address'];

$link = mysqli_connect($endpoint,"master","secret99","records") or die("Error " . mysqli_error($link));
// check connection
if (mysqli_connect_errno()) {
    printf("Connect failed: %s\n", mysqli_connect_error());
    exit();
}
// Prepared statement
if (!($stmt = $link->prepare("INSERT INTO items (id, email,phone,filename,s3rawurl,s3finishedurl,status,issubscribed) VALUES (NULL,?,?,?,?,?,?,?)"))) {
    echo "Prepare failed: (" . $link->errno . ") " . $link->error;
}
//echo "Till now working";
$email = $_POST['useremail'];
$phone = $_POST['phone'];
$s3rawurl = $url;
$filename = basename($_FILES['userfile']['name']);
$s3finishedurl = $urlmod;
$status =0;
$issubscribed=0;
$stmt->bind_param("sssssii",$email,$phone,$filename,$s3rawurl,$s3finishedurl,$status,$issubscribed);
if (!$stmt->execute()) {
    echo "Execute failed: (" . $stmt->errno . ") " . $stmt->error;
}
echo "<br>";
echo "<br>";
echo nl2br();
printf("Number of row inserted: %d ", $stmt->affected_rows);
$stmt->close();*/
?>