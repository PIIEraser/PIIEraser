#!/bin/bash
set -e

STACK_NAME="pii-eraser-test-vpc"
REGION="eu-south-2"
ENV_NAME="pii-test-net"

echo "=== PII Eraser: Test Network Provisioner ==="
echo "Creating a standalone VPC using vpc.yaml..."

# 1. Deploy the VPC Stack
# We reuse the existing vpc.yaml but deploy it as a standalone stack
aws cloudformation deploy \
  --template-file vpc.yaml \
  --stack-name $STACK_NAME \
  --parameter-overrides EnvironmentName=$ENV_NAME \
  --region $REGION

echo ""
echo "✅ Network Stack Deployed."

# 2. Fetch and Display Outputs for deploy.sh
echo "Fetching resource IDs..."

VPC_ID=$(aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --region $REGION \
    --query "Stacks[0].Outputs[?OutputKey=='VpcId'].OutputValue" \
    --output text)

SUBNETS=$(aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --region $REGION \
    --query "Stacks[0].Outputs[?OutputKey=='PrivateSubnetIds'].OutputValue" \
    --output text)

echo "------------------------------------------------"
echo "👇 COPY THESE VALUES FOR DEPLOY.SH (OPTION 2) 👇"
echo "------------------------------------------------"
echo "VPC ID:            $VPC_ID"
echo "Private Subnets:   $SUBNETS"
echo "------------------------------------------------"
echo "After testing, remember to delete the network manually with this command:"
echo "aws cloudformation delete-stack --stack-name pii-eraser-test-vpc --region eu-south-2"
echo "------------------------------------------------"