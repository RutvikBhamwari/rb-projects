#!/bin/bash

echo ............................................................Destroying the Environment for MP2 App..............................................................................

echo .................................................................Deleting DynamoDB..................................................................................
#Deleting DynamoDB Table
aws dynamodb delete-table --table-name Records-rb

echo ............................................................Deleting the SQS Queue..............................................................................

#Deleting SQS Message Queue
SQSURL=$(aws sqs get-queue-url --queue-name rb-queue)
aws sqs delete-queue --queue-url $SQSURL

echo ............................................................Deleting the Lambda Function..............................................................................

#Deleting Lambda Function
aws lambda delete-function --function-name rb-lambda-function

echo ..................................................................Deleting the SNS Topic..............................................................................


#Deleting SNS Subscription Topic
TOPICARN=$(aws sns list-topics --query Topics[].TopicArn)
aws sns delete-topic --topic-arn $TOPICARN

echo ..............................................................Deleting the Autoscaling group..............................................................................

#Deleting Autoscaling Group
aws autoscaling delete-auto-scaling-group --auto-scaling-group-name rb-asg --force-delete

echo ............................................................Deleting the Launch Configuration..............................................................................

#Deleting Launch Configuration
aws autoscaling delete-launch-configuration --launch-configuration-name rb-launch-config

echo ............................................................Deleting the Load Balancers..............................................................................

#Deleting Load Balancer
aws elb delete-load-balancer --load-balancer-name rb-load-balancer

echo ............................................................Environment Destroyed..............................................................................


#Waiting the instances to be terminated


#DELETING AUTO SCALING GROUP  
#aws autoscaling delete-auto-scaling-group --auto-scaling-group-name my-asg --force-delete

#WAITING FOR THE INSTANCES TO GET DELETED









#*****************************old old old old script script script***********************************************

#aws ec2 terminate-instances --instance-ids $(aws ec2 describe-instances --instance-ids --query "Reservations[*].Instances[*].[InstanceId]")

#ID=$(aws ec2 describe-instances --instance-ids --filter "Name=instance-state-code,Values=16" --query "Reservations[*].Instances[*].[InstanceId]")
#RDS=$(aws rds describe-db-instances --query "DBInstances[?DBInstanceStatus=='available'].[DBInstanceIdentifier]")
#LB=$(aws elb describe-load-balancers --query "LoadBalancerDescriptions[*].[LoadBalancerName]")
#LBInstances=$(aws elb describe-load-balancers --query "LoadBalancerDescriptions[?LoadBalancerName=='$LB'].Instances[*]")


#aws elb deregister-instances-from-load-balancer --load-balancer-name $LB --instances $LBInstances

#aws elb wait instance-deregistered --load-balancer-name $LB --instances $LBInstances

#aws elb delete-load-balancer --load-balancer-name $LB

#aws ec2 terminate-instances --instance-ids $ID

#aws ec2 wait instance-terminated

#aws rds delete-db-instance --db-instance-identifier $RDS --skip-final-snapshot






#aws elb describe-load-balancers --query "LoadBalancerDescriptions[?LoadBalancerName=="$LB"].[InstanceId]"