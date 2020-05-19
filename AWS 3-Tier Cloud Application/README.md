# AWS 3-Tier Photo Rendering Cloud Application 
## Overview
This is an photo uplaoding app which uses three tier monolithic system. It has three pages starting from the index page, submit page and the last one is gallery page. The index page basically presents a form with an option to either upload an image or load the gallery. If you like to uplaod an image you can select a jpg file, put in your eamil address and phone number and click on submit button. The page will be directed over to the submit page which gives you a basic detail of the uplaod you just did. That page will show the email as account identity and would give some basic description like the if the file is valid or not, name, type, tmp_name, error and size. All this will be picked up from the array read by the $FILE function. Once the submit page is activated the image would be uploaded in the s3 raw bucket, after this an uuid would be generated and all the above the details would be stored as items in dynamoDB. After this queue is generated. Which has uuid and email in it. After this the notification will be published to Lambda in order to trigger it. For further deatils on Lambda refer Lambda section.
And if you fill in the email id in the text box of the load gallery button and click on the load gallery button, it will direct you over to the gallery page. It will show two images one from raw bucket and one from the finished bucket. Both of these images are shown through a link that is being fetched from the same items table. sThe one from the raw bucket is the one that exactly the one you uploaded but the one coming from the finished bucket is the converted into a thumbnail. At the end of the page it will show the number of images that you have in your gallery.

## Create-env.sh File
In order to start with the app we need to set up an environment on which the application would work. For this we launch the Create-env.sh file with the parameters as defined:

$1 will be ami

$2 will be count (Not used but still insert it)

$3 will be Instance Type

$4 will be KeyPair Name

$5 will be Security Group ID

$6 will be IAM profile/Role

$7 will be Availability Zone

$8 will be AWS Lambda Role

Once you run the create-env.sh script with all the parameters. 
The script will start to create environment first starting to create Launch Configuration, Load Balancer, Auto Scaling Group, SQS,SNS, DynamoDB, Lambda Function, adds SNS Permission/Trigger to lambda function, subscribes Lambda with SNS Topic, and waits until the desired number of instances are running. Once this all is done your environment is ready.

## Install-app-env.sh File
This shell script file is launcehd during the processing of the command to create the EC2 instances in create-env.sh. This file basically runs within the server. This shell script holds all the pre-requisite installion required in order to run program on the server side. The shell script starts with the installation of the apache2, php, php-gd, mysql-server, php7.2-xml, php-curl, php-zip, unzip, php-cli, php-mysql and mysql-client. After all these installtiaions after completed, it will move on to cloning the our private repository at github.com. This repository has the php files that holds the code of the index, submit and the gallery page. Once the repository is cloned these pages would be copied to the default root folder of the web server in order to make them appear on the webpage browser. Once all the cloning and coping is done the directory is changed to home ubuntu and here the composer would be made by using the user as ubuntu. After the composer program the vendor file would be generated at same directory where the composer has been built. Once this commands in the install-app-env.sh file is compeleted after executuion it will go back to create-env.sh file and move on to the next functions present there.

## Lambda Function
This is a python script that is imported from in the lambda at time of its creation in the create-env.sh. For this application the lambda function is activated at the time when it is triggered from the submit page after creating a queue. Once the lambda is triggered it will read the queue and fetch the UUID and email sent in the queue. With these value it will fetch the raw url, name of the image and, the phone number from the dynamoDB. Once all this is fetched it will downlaod the image from S3 and will process it throught image processing code from pillow library. Once the image is processed it will be uploaded to your finished bucket and the link would be updated in the dynamoDB. Once the dynamoDB is updated the lambda will publish message to the phone number fetched from the dynamoDB and would publish the rendered image link to the user phone number.

## Destroy.sh File
This shell script destroys the whole enviroment. Starting from DynamoDB, the SQS service, then th eLambdda function, then the SNS,then the AutoScaling group, then the Launch Configuration, and then the Load Balancers. As these all are deleted the our environment would be fully destroyed.
