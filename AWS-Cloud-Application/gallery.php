<?php
session_start();

#Storing user input email to a variable
$email = $_POST['emailload'];

require '/home/ubuntu/vendor/autoload.php';

use Aws\DynamoDb\DynamoDbClient;

$client = new DynamoDbClient([
    #'profile' => 'default',
    'region'  => 'us-east-1',
    'version' => 'latest'
]);

$result = $client->scan([
    'ExpressionAttributeNames' => [
        '#S3R' => 'S3finishedurl',
        '#S3F' => 'S3rawurl',
    ],
    'ExpressionAttributeValues' => [
        ':e' => [
            'S' => $email,
        ],
    ],
    'FilterExpression' => 'Email = :e',
    'ProjectionExpression' => '#S3F, #S3R',
    'TableName' => 'Records-rb',
]);
#print_r($result);
# retrieve the number of elements being returned -- use this to control the for loop
$len = $result['Count'];
echo "Len: " . $len . "\n";
#print_r($result['Items'][0]['S3rawurl']['S']);
echo "\n";
#print_r($result['Items'][0]['S3finishedurl']['S']);
echo "\n";
# for loop to iterate through all the elements of the returned matches
for ($i=0; $i < $len; $i++) {
    echo "\n";
    #print_r($result['Items'][$i]['S3rawurl']['S']);
    echo "<img src =\" " . ($result['Items'][$i]['S3rawurl']['S']) . "\" /><img src =\"" . ($result['Items'][$i]['S3finishedurl']['S']) . "\"/>";
    echo "\n";
    #print_r($result['Items'][$i]['S3finishedurl']['S']);
    #echo "<img src =\"" . ($result['Items'][$i]['S3finishedurl']['S']) . "\"/>";
}
/*
session_start();
$email = $_POST["emailload"];
echo ("Account email: ".$email);
require '/home/ubuntu/vendor/autoload.php';
 
use Aws\Rds\RdsClient;
$client = new Aws\Rds\RdsClient([
'region'  => 'us-east-1',
'version'=>'latest',
]);
 
$result = $client->describeDBInstances(array(
    'DBInstanceIdentifier' => 'rb-instance',
));
 
$endpoint = $result['DBInstances'][0]['Endpoint']['Address'];;

$link = mysqli_connect($endpoint,"master","secret99","records") or die("Error " . mysqli_error($link));

if (mysqli_connect_errno()) {
    printf("Connect failed: %s\n", mysqli_connect_error());
    exit();
}

$link->real_query("SELECT * FROM items where email='$email'");
$res = $link->use_result();
echo "<br>";
echo nl2br("Your gallery is loaded");
echo "<br>";
$rowno=0;
$imageno=1;
while ($row = $res->fetch_assoc()) 
{   
    echo "<br>";
    echo "<img src =\" " . $row['s3rawurl'] . "\" /><img src =\"" .$row['s3finishedurl'] . "\"/>";
    echo "<br>";
    echo nl2br("Image: ".$imageno);
    $rowno=$rowno+1;
    $imageno=$imageno+1;
}
echo "<br>";
echo nl2br("You have ".$rowno." picture(s) in your gallery.");
$link->close();
?>*/
?>





