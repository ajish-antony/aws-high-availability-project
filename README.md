# High Availability Application
## ( Dev & Prod Environments - Deployed in AWS Cloud )


[![Build Status](https://travis-ci.org/joemccann/dillinger.svg?branch=master)](https://travis-ci.org/joemccann/dillinger)

Here is a project with their requirements was to build a dev and prod environment for a PHP website (WordPress application). It needs to be built with high availability and fault tolerance which should be completely deployed in the AWS cloud. Several AWS services have been made use of for fulling the requirement. 
The basic outline of the project is that there is a dev environment where the developers have been working on the application and once it completes the testing, it will be deployed into the production means to the outside world. RDS is used as the database, where the master is used in the dev environment and replicas in the production environment. To make the deployment procedure easier I have implemented a script that will sync the database master and replicas,  also will sync files from the dev to production.  A detailed explanation of the project is given below. 


## Features

- Resilient as it will handle failure without service disruption or data loss
- Ensuring that critical system components have another identical component with the same data, that can take over in case of failure
- Implementation with many services that make the configuration simplifies and easy to manage

## Cons

- As the EFS is used as the file storage and if it is using in the standard storage class, there may chance for some speed and price concerns. To overcome that scenario, can make use of the NFS storage on instance store backed instance. At the same time, keep in mind that data on Instance store volume is LOST for the following scenarios,  when a failure of an underlying drive, Stopping an EBS-backed instance where instance store are attached as additional volumes or in the case of termination of the Instance.

## Resources Used

- VPC ( Subnets, Route table, IGW )
- Route53 ( Public & Private Hosted Zone, Weighted and Simple Routing Policies )
- ALB ( Target Groups, Host Header Routing )
- EC2 Instances ( Security groups, NACL )
- RDS ( Multi AZ, Replicas )
- ACM ( SSL )
- ASG 
- EFS
- S3
- CloudWatch
- SNS
- IAM

## Prerequisites
- Knowledge in AWS services 
- IAM user with necessary privileges

## Architecture
![
alt_txt
](https://i.ibb.co/jfjLF2S/rds-6.jpg)

## How it has been Configured

Initially configured the dev environment and begins with the creation of VPC with subnets and necessary routings. Further moved forward with the RDS master which will be the main database used for the application development and has been configured in Multi-AZ. After the development and testing, data from the rds will be synced with the production later. For the same purpose, created two replicas of the master RDS. Route 53 is configured with the private hosted zone and master RDS pointed via simple routing. And the Replica is pointed via weighted routing. Then comes the website file storage in which here used is EFS. So it is mounted to the document root of the new newly created EC2 instance. Next proceeds with the installation of necessary packages and configured the application. After the completion created an AMI of the instance and configured an Autoscaling group with the same. For traffic control, an Application Load Balancer is configured and via header routing, it's routed to the dev environment. However, for accessing the instance of the production and dev a bastion server is set up and configured with security groups, NACL rules with maximum security.

After the completion of the above configurations, the production part comes. Created an Ec2 instance, mounted the efs in a different created location, and then copied the wp-config to the document root.
Then further created AMI and ASG as similar in the dev environment. At the same time while creating the launch configuration, provided with a user-data script that will copy the application files from the dev to production, also exclude the wp-config.php as it contains static data. The user-data script that has been used is provided below.
```sh
#!/bin/bash
rsync -av --exclude=wp-config.php /dev.efs_directory/ /var/www/html
chown   -R apache:apache /var/www/html/*
```
Created a hosted zone in Route53, here it's a public hosted zone for the production environment. The ALB updated the host header to forward the traffic to the production server. For logging the access logs an S3 bucket has been allocated. For monitoring the utilisations,CloudWatch is being created and for notifying any alerts from the production, SNS is integrated with the cloud watch. So the required admin/developers will be notified via email and message from the SNS subscription created. 


## Script for syncing the RDS Master and Replica

Here the script is used for syncing the RDS between the dev and prod (master and replica). As it will start the syncing once the script is executed and the same can be used for stopping once the sync is completed. At the time of syncing the database, here the files from the dev (efs) will also be updated in the prod excluding the static file.
To make use of the script update the replica1,replica2, user, password, Rsync path with your details.

```sh
#!/bin/bash
replica1=master-replica-1.czzuhjvwmmvx.us-east-1.rds.amazonaws.com
replica2=master-replica-2.czzuhjvwmmvx.us-east-1.rds.amazonaws.com
user=admin
password=admin123
option=$1
if [[ -z "$option" ]]; then
    echo "Invalid Input"
    exit 1
fi

if [ $option == 'start' ]
then

    mysql -u $user -p$password -h $replica1 -e "CALL mysql.rds_start_replication;"
    mysql -u $user -p$password -h $replica2 -e "CALL mysql.rds_start_replication;"

    rsync -av --exclude=wp-config.php /dev.efs_directory/ /var/www/html/

        elif [ $option == 'stop' ]
            then
                mysql -u $user -p$password -h $replica1 -e "CALL mysql.rds_stop_replication;"
                mysql -u $user -p$password -h $replica2 -e "CALL mysql.rds_stop_replication;"
else                                                                                                    
  echo "Wrong Input"
fi
```

## Conclusion

So this was the project that was required to deploy completely in the AWS cloud and which is made possible with the several resources offered by the AWS.  



### ⚙️ Connect with Me

<p align="center">
<a href="mailto:ajishantony95@gmail.com"><img src="https://img.shields.io/badge/Gmail-D14836?style=for-the-badge&logo=gmail&logoColor=white"/></a>
<a href="https://www.linkedin.com/in/ajish-antony/"><img src="https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white"/></a> 
