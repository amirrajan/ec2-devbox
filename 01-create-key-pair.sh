#!/bin/bash

REGION=us-east-1
KEY_NAME=ec2-devbox-key-pair

rm "${KEY_NAME}.pem"

# Create key pair and save PEM locally
aws ec2 create-key-pair --region "$REGION" --key-name "$KEY_NAME" --key-type ed25519 --key-format pem \
  --query 'KeyMaterial' --output text > "${KEY_NAME}.pem"
chmod 400 "${KEY_NAME}.pem"
