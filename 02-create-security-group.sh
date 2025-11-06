#!/bin/bash

REGION=us-east-1
SG_NAME=ec2-devbox-security-group

# Retrieve the default VPC ID and save it to a temporary file
VPC_ID=$(aws ec2 describe-vpcs --region "$REGION" --filters Name=isDefault,Values=true --query 'Vpcs[0].VpcId' --output text)
echo "$VPC_ID" > vpc_id.txt

# Create security group "ec2-devbox" (allow all inbound/outbound)
SG_ID=$(aws ec2 create-security-group --region "$REGION" --group-name "$SG_NAME" --description "ec2-devbox allow all" --vpc-id "$VPC_ID" --query 'GroupId' --output text)
echo "$SG_ID" > sg_id.txt

# Inbound allow all (IPv4 and IPv6)
aws ec2 authorize-security-group-ingress --region "$REGION" --group-id "$SG_ID" --ip-permissions IpProtocol=-1,IpRanges='[{CidrIp=0.0.0.0/0}]'
aws ec2 authorize-security-group-ingress --region "$REGION" --group-id "$SG_ID" --ip-permissions IpProtocol=-1,Ipv6Ranges='[{CidrIpv6=::/0}]'

# Outbound is already "allow all IPv4" by default; add IPv6 egress to match
aws ec2 authorize-security-group-egress --region "$REGION" --group-id "$SG_ID" --ip-permissions IpProtocol=-1,Ipv6Ranges='[{CidrIpv6=::/0}]'
