#!/bin/bash
set -e

# Configuration
STACK_NAME="pii-eraser-stack"
REGION="eu-south-2"

echo "=== PII Eraser Enterprise Deployment ==="
echo "Region: $REGION"
echo "Stack Name: $STACK_NAME"

# 1. Validation: Ensure we are in the right folder
if [ ! -f "main.yaml" ] || [ ! -f "common.yaml" ]; then
    echo "❌ Error: Templates not found."
    echo "   Please run this script from the folder containing 'main.yaml'."
    exit 1
fi

# 2. Config Loading: Check for config.yaml in the current folder
CONFIG_B64=""
CONFIG_STATUS="ℹ️  Using default built-in configuration"
if [ -f "config.yaml" ]; then
    echo "✅ Found 'config.yaml' in current directory. Encoding..."
    CONFIG_B64=$(cat "config.yaml" | base64 | tr -d '\n')
    CONFIG_STATUS="✅ Loaded from config.yaml"
else
    echo "ℹ️  'config.yaml' not found in current directory. Using defaults."
fi

# 3. Interactive Inputs
echo ""

# --- Image URI Validation Loop ---
IMAGE_URI=""
while [[ -z "$IMAGE_URI" ]]; do
    read -p "Enter Container Image URI (Required): " IMAGE_URI
    if [[ -z "$IMAGE_URI" ]]; then
        echo "⚠️  Image URI cannot be empty. Please enter a valid URI (e.g., public.ecr.aws/your-org/pii-eraser:latest)."
    fi
done
# ------------------------------------------

echo ""
echo "Choose Network Strategy:"
echo "1) Create a NEW secure VPC (Recommended for testing)"
echo "2) Deploy into EXISTING VPC"
read -p "Selection [1]: " NET_CHOICE
NET_CHOICE=${NET_CHOICE:-1}

echo ""
echo "Choose Compute Platform:"
echo "1) Fargate (Serverless)"
echo "2) EC2 (Ensures high performance instance types)"
read -p "Selection [1]: " COMPUTE_CHOICE
COMPUTE_CHOICE=${COMPUTE_CHOICE:-1}

echo ""
read -p "Enter Minimum Containers [1]: " MIN_CONTAINERS
MIN_CONTAINERS=${MIN_CONTAINERS:-1}

if [ "$MIN_CONTAINERS" -eq 0 ]; then
    echo "⚠️  You selected 0 containers."
    echo "   Setting to 0 means you must use 'manage_service.py' to manually start and stop the service."
    read -p "   Are you sure? (y/n): " CONFIRM_ZERO
    if [ "$CONFIRM_ZERO" != "y" ]; then
        echo "   Reverting to default (1)."
        MIN_CONTAINERS=1
    fi
fi

echo ""
echo "Deployment Mode:"
echo "1) 🚀 Deploy Live"
echo "2) 🧪 Dry Run (Create Change Set)"
read -p "Selection [1]: " DEPLOY_MODE
DEPLOY_MODE=${DEPLOY_MODE:-1}

# 4. Parameter Construction
PARAMS="Base64Config=$CONFIG_B64 MinContainers=$MIN_CONTAINERS ImageUri=$IMAGE_URI"

# Handle Compute
COMPUTE_DISPLAY="Fargate"
if [ "$COMPUTE_CHOICE" == "2" ]; then
    PARAMS="$PARAMS DeploymentPlatform=EC2"
    COMPUTE_DISPLAY="EC2 (See main.yaml for Instance details)"
else
    PARAMS="$PARAMS DeploymentPlatform=FARGATE"
fi

# Handle Network
NET_DISPLAY="New Secure VPC"
if [ "$NET_CHOICE" == "2" ]; then
    echo ""
    read -p "Enter VPC ID: " VPC_ID
    read -p "Enter Private Subnet IDs (comma separated): " SUBNET_IDS
    PARAMS="$PARAMS CreateNewVpc=false ExistingVpcId=$VPC_ID ExistingSubnetIds=$SUBNET_IDS"
    NET_DISPLAY="Existing VPC ($VPC_ID) Existing Subnet Ids ($SUBNET_IDS)"
else
    PARAMS="$PARAMS CreateNewVpc=true"
fi

# 5. S3 Artifact Handling (Required for Nested Stacks)
echo ""
echo "--- S3 Setup for Templates ---"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text --region $REGION)
DEFAULT_BUCKET="pii-eraser-deploy-${ACCOUNT_ID}-${REGION}"
read -p "Enter S3 Bucket for artifacts [$DEFAULT_BUCKET]: " ARTIFACT_BUCKET
ARTIFACT_BUCKET=${ARTIFACT_BUCKET:-$DEFAULT_BUCKET}

# 6. Confirmation Summary
echo ""
echo "=========================================="
echo "       CONFIGURATION SUMMARY"
echo "=========================================="
echo "Stack Name:      $STACK_NAME"
echo "Region:          $REGION"
echo "Image URI:       $IMAGE_URI"
echo "Config File:     $CONFIG_STATUS"
echo "Network:         $NET_DISPLAY"
echo "Platform:        $COMPUTE_DISPLAY"
echo "Min Containers:  $MIN_CONTAINERS"
echo "Mode:            $([ "$DEPLOY_MODE" == "1" ] && echo "🚀 Live Deployment" || echo "🧪 Dry Run")"
echo "S3 Bucket:       $ARTIFACT_BUCKET"
echo "=========================================="
read -p "Proceed with deployment? (y/n): " CONFIRM
if [ "$CONFIRM" != "y" ]; then
    echo "Aborted by user."
    exit 0
fi

# 7. Package & Execution

# Check if bucket exists, if not create it
if ! aws s3api head-bucket --bucket "$ARTIFACT_BUCKET" 2>/dev/null; then
    echo "Bucket '$ARTIFACT_BUCKET' not found. Creating..."
    if [ "$REGION" == "us-east-1" ]; then
        aws s3api create-bucket --bucket "$ARTIFACT_BUCKET" --region "$REGION"
    else
        aws s3api create-bucket --bucket "$ARTIFACT_BUCKET" --region "$REGION" --create-bucket-configuration LocationConstraint="$REGION"
    fi
fi

echo "Packaging templates to S3..."
aws cloudformation package \
    --template-file main.yaml \
    --s3-bucket "$ARTIFACT_BUCKET" \
    --output-template-file packaged-deploy.yaml \
    --region "$REGION"

echo ""
DEPLOY_ARGS=""
if [ "$DEPLOY_MODE" == "2" ]; then
    echo "Creating Change Set (Dry Run)..."
    DEPLOY_ARGS="--no-execute-changeset"
else
    echo "Deploying Stack... (This will take some minutes)"
fi

aws cloudformation deploy \
  --template-file packaged-deploy.yaml \
  --stack-name $STACK_NAME \
  --parameter-overrides $PARAMS \
  --region $REGION \
  --capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND \
  $DEPLOY_ARGS

# 8. Output Results
if [ "$DEPLOY_MODE" == "1" ]; then
    echo ""
    echo "=== Deployment Complete ==="
    SERVICE_URL=$(aws cloudformation describe-stacks \
        --stack-name $STACK_NAME \
        --region $REGION \
        --query "Stacks[0].Outputs[?OutputKey=='ServiceEndpoint'].OutputValue" \
        --output text)
    echo "Application URL: $SERVICE_URL"
else
    echo ""
    echo "=== Dry Run Complete ==="
    echo "Check the AWS CloudFormation Console to view the generated Change Set."
fi

# Cleanup local packaged file
rm -f packaged-deploy.yaml