#!/bin/bash
set -e

STACK_NAME="pii-eraser-stack"
REGION="eu-south-2"

echo "=== PII Eraser Cleanup ==="
echo "Region: $REGION"
echo ""
echo "⚠️  WARNING: This will permanently delete the stack '$STACK_NAME'."
echo ""
echo "Please ensure the following pre-requisites are met to avoid a DELETE_FAILED error:"
echo "1. Service is scaled to 0 instances."
echo "2. Any external resources that reference this stack have been deleted."
echo "   (Examples: Manually created Security Groups, or test instances)."
echo ""
read -p "Are you sure you want to proceed? (y/n): " CONFIRM

if [ "$CONFIRM" != "y" ]; then
    echo "Aborted."
    exit 0
fi

echo "Initiating stack deletion..."
aws cloudformation delete-stack --stack-name $STACK_NAME --region $REGION

echo "Waiting for stack deletion to complete... (This usually takes 2-5 minutes)"
aws cloudformation wait stack-delete-complete --stack-name $STACK_NAME --region $REGION

echo "✅ Stack '$STACK_NAME' has been successfully deleted."