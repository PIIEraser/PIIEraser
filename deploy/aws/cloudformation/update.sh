#!/bin/bash
set -e

# Configuration
STACK_NAME="pii-eraser-stack"
REGION="eu-south-2"

echo "=== PII Eraser: Fast Config Update ==="

# Initialize parameters array
params=()

# --- Config.yaml ---
# LOGIC: Always read the current local state.
# If config.yaml exists -> Use it.
# If config.yaml is missing -> User deleted it (Intentional) -> Send empty config.
if [ -f "config.yaml" ]; then
    echo "✅ Found 'config.yaml'. Encoding..."
    val=$(cat "config.yaml" | base64 | tr -d '\n')
    params+=("ParameterKey=Base64Config,ParameterValue=$val")
else
    echo "ℹ️  No 'config.yaml'. Clearing config."
    params+=("ParameterKey=Base64Config,ParameterValue=")
fi

# 2. Handle Image URI
read -p "New Image URI (Enter to keep existing): " val
if [ -n "$val" ]; then
    params+=("ParameterKey=ImageUri,ParameterValue=$val")
else
    params+=("ParameterKey=ImageUri,UsePreviousValue=true")
fi

# 3. Handle Scaling (Min/Max)
read -p "New Min Containers (Enter to keep existing): " min_val
if [ "$min_val" == "0" ]; then
    echo "⚠️  Setting to 0 means you must use 'manage_service.py' to manually start and stop the service."
    read -p "   Are you sure? (y/n): " confirm
    [[ "$confirm" != "y" ]] && min_val="" # Reset to empty to trigger UsePreviousValue logic
fi

if [ -n "$min_val" ]; then
    params+=("ParameterKey=MinContainers,ParameterValue=$min_val")
else
    params+=("ParameterKey=MinContainers,UsePreviousValue=true")
fi

read -p "New Max Containers (Enter to keep existing): " max_val
if [ -n "$max_val" ]; then
    params+=("ParameterKey=MaxContainers,ParameterValue=$max_val")
else
    params+=("ParameterKey=MaxContainers,UsePreviousValue=true")
fi

# 4. Preserve Static Parameters
# We loop through all other parameters and explicitly tell CloudFormation to keep their current values.
# This prevents the stack from reverting to defaults (e.g., switching back to Fargate from EC2).
static_keys=(
  "EnvironmentName" "CreateNewVpc" "ExistingVpcId" "ExistingSubnetIds"
  "DeploymentPlatform" "ComputeType" "Ec2InstanceType" "ContainerCpu" "ContainerMemory"
  "RequestTimeout"
)

for key in "${static_keys[@]}"; do
    params+=("ParameterKey=$key,UsePreviousValue=true")
done

# 5. Execution
aws cloudformation update-stack \
    --stack-name "$STACK_NAME" \
    --use-previous-template \
    --parameters "${params[@]}" \
    --capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND \
    --region "$REGION"

echo "✅ Update initiated successfully!"
echo "Waiting for update to complete... (Ctrl+C to exit wait, update will continue in background)"

aws cloudformation wait stack-update-complete --stack-name "$STACK_NAME" --region "$REGION"

echo "🚀 Stack update finished."