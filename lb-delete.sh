#!/bin/bash

echo "Please input your AWS profile name:"
read PROFILE

echo "Please input your AWS region (e.g. us-west-2):"
read REGION

while true; do
  echo "Fetching load balancers..."
  LOAD_BALANCERS=$(aws elbv2 describe-load-balancers --region "$REGION" --profile "$PROFILE" | jq -c '.LoadBalancers[]')
  
  echo "Checking for deletion protection..."
  PROTECTED_LBS=""
  
  for LB in $(echo "$LOAD_BALANCERS" | jq -r '.LoadBalancerArn'); do
    ATTRIBUTES=$(aws elbv2 describe-load-balancer-attributes --load-balancer-arn "$LB" --region "$REGION" --profile "$PROFILE")
    DELETION_PROTECTION=$(echo "$ATTRIBUTES" | jq -c 'select(.Attributes[] | .Key=="deletion_protection.enabled" and .Value=="true")')
    if [ -n "$DELETION_PROTECTION" ]; then
      PROTECTED_LBS+=$(echo "$LOAD_BALANCERS" | jq -c 'select(.LoadBalancerArn=="'$LB'")')
    fi
  done

  echo "Protected Load Balancers:"
  echo "$PROTECTED_LBS"

  echo "Would you like to remove protection from these load balancers? (yes/no)"
  read RESP

  if [ "$RESP" = "yes" ]; then
    for LB in $(echo "$PROTECTED_LBS" | jq -r '.LoadBalancerArn'); do
      aws elbv2 modify-load-balancer-attributes --load-balancer-arn "$LB" --attributes Key=deletion_protection.enabled,Value=false --region "$REGION" --profile "$PROFILE"
    done
  fi

  echo "Fetching unprotected load balancers..."
  UNPROTECTED_LBS=""

  for LB in $(echo "$LOAD_BALANCERS" | jq -r '.LoadBalancerArn'); do
    ATTRIBUTES=$(aws elbv2 describe-load-balancer-attributes --load-balancer-arn "$LB" --region "$REGION" --profile "$PROFILE")
    DELETION_PROTECTION=$(echo "$ATTRIBUTES" | jq -c 'select(.Attributes[] | .Key=="deletion_protection.enabled" and .Value=="false")')
    if [ -n "$DELETION_PROTECTION" ]; then
      UNPROTECTED_LBS+=$(echo "$LOAD_BALANCERS" | jq -c 'select(.LoadBalancerArn=="'$LB'")')
    fi
  done

  echo "Unprotected Load Balancers:"
  echo "$UNPROTECTED_LBS"

  VPC_LBS=$(echo "$UNPROTECTED_LBS" | jq -r 'group_by(.VpcId)[] | {VpcId: .[0].VpcId, LoadBalancers: map({LoadBalancerName, LoadBalancerArn})}')

  select VPC in $(echo "$VPC_LBS" | jq -r '.VpcId'); do
    echo "Select Load Balancer to delete: "
    select LB in $(echo "$VPC_LBS" | jq -r 'select(.VpcId=="'$VPC'") | .LoadBalancers[].LoadBalancerName'); do
      LB_ARN=$(echo "$VPC_LBS" | jq -r 'select(.VpcId=="'$VPC'") | .LoadBalancers[] | select(.LoadBalancerName=="'$LB'") | .LoadBalancerArn')
      echo "Deleting $LB..."
      aws elbv2 delete-load-balancer --load-balancer-arn "$LB_ARN" --region "$REGION" --profile "$PROFILE"
      break
    done
    break
  done

  echo "Would you like to delete another load balancer? (yes/no)"
  read ANOTHER

  if [ "$ANOTHER" != "yes" ]; then
    break
  fi
done
