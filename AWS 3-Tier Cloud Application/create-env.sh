#!/bin/bash
  
echo ............................................................Building Environment for MP2 App..............................................................................

echo ...........................................................Creating Launch confirgurations..........................................................................
aws autoscaling create-launch-configuration --launch-configuration-name rb-launch-config --image-id $1 --instance-type $3 --key-name $4  --security-groups $5 --user-data file://install-app-env-front-end.sh --iam-instance-profile $6

#aws autoscaling create-launch-configuration --launch-configuration-name rb-launch-config --key-name Assign5keypair1 --image-id ami-0db5f9c013638aaa6 --security-groups sg-029f3b556d263eeeb --user-data file://install-app-env-front-end.sh --instance-type t2.micro --iam-instance-profile Sem-3-2019

echo ................................................................Creating Load Balancer...............................................................................
 
#create load balancer
aws elb create-load-balancer --load-balancer-name rb-load-balancer --listeners "Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP,InstancePort=80" --security-groups $5 --availability-zones $7

echo ............................................................Load Balancer Health check start...............................................................................

#Fetching only load balancers
LB=$(aws elb describe-load-balancers --query "LoadBalancerDescriptions[*].[LoadBalancerName]")

#load balancer health check
aws elb configure-health-check --load-balancer-name $LB --health-check Target=HTTP:80/index.html,Interval=30,UnhealthyThreshold=2,HealthyThreshold=2,Timeout=3

echo ............................................................Launching Auto Scaling Group...............................................................................

#Launching Auto Scaling Group
aws autoscaling create-auto-scaling-group --auto-scaling-group-name rb-asg --launch-configuration-name rb-launch-config --min-size 3 --max-size 4 --desired-capacity 3 --termination-policies "OldestInstance" --availability-zones $7 --load-balancer-name $LB

echo ....................................................................Creating SQS.........................................................................................

#CREATING SQS QUEUE
aws sqs create-queue --queue-name rb-queue

echo ....................................................................Creating SNS.........................................................................................

#CREATING SNS TOPIC
aws sns create-topic --name rb-topic

echo ..................................................................Creating DynamoDB......................................................................................

#CREATING DYNAMODB
aws dynamodb create-table --table-name Records-rb --attribute-definitions AttributeName=Receipt,AttributeType=S AttributeName=Email,AttributeType=S --key-schema AttributeName=Receipt,KeyType=HASH AttributeName=Email,KeyType=RANGE --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
#aws dynamodb describe-table --table-name Records-rb


#ZIPiING THE LAMBDA FUNCTION FILE
#zip rb-lambda-function.zip rb-lambda-function.py

#FETCHING THE SNS TOPIC
SNSID=$(aws sns list-topics --query 'Topics[0].TopicArn')

echo ...............................................................Creating Lambda Function..................................................................................

#CREATE A LAMBDA FUNCTION
aws lambda create-function --function-name rb-lambda-function --runtime python3.7 --zip-file fileb://rb-lambda-function.zip --handler rb-lambda-function.lambda_handler --role $8

#FETCHING LAMBDA ARN
LARN=$(aws lambda list-functions --query 'Functions[0].FunctionArn')

echo ............................................................Addinging SNS Permission/Trigger.............................................................................

#ADDING PERMISIONS TO LAMDA
aws lambda add-permission --function-name rb-lambda-function --action lambda:InvokeFunction --statement-id sns --principal sns.amazonaws.com --source-arn $SNSID

echo ..............................................................Subscribing Lambda with SNS Topic................................................................................

#CREATING SUBSCRIPTION FOR LAMBDA
aws sns subscribe --topic-arn $SNSID --protocol lambda --notification-endpoint $LARN

echo ..............................................................Waiting for instances to get ready................................................................................

#WAITING FOR INSTANCES TO GET READY
aws ec2 wait instance-status-ok

echo ..................................................................Environment is Up and Running.....................................................................................

