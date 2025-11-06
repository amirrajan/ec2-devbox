#!/bin/bash

REGION=us-east-1
KEY_NAME=ec2-devbox-key-pair
SG_ID=$(cat sg_id.txt)

# Retrieve the latest Amazon Linux 2023 AMI ID and save it to a temporary file
AMI_ID=$(aws ssm get-parameter --region "$REGION" --name /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64 --query 'Parameter.Value' --output text)
echo "$AMI_ID" > ami_id.txt

# Launch EC2 r6id.2xlarge with the key and security group
aws ec2 run-instances --region "$REGION" --image-id "$AMI_ID" --instance-type r6id.2xlarge \
  --key-name "$KEY_NAME" --security-group-ids "$SG_ID" \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=ec2-devbox}]' --count 1

aws ec2 describe-instances --filters "Name=tag:Name,Values=ec2-devbox" --query "Reservations[*].Instances[*].PublicIpAddress" --output text > ip_address.txt
aws ec2 describe-instances --filters "Name=tag:Name,Values=ec2-devbox" --query "Reservations[*].Instances[*].InstanceId" --output text > instance_id.txt
