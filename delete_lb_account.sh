#!/bin/bash

# Prompt for AWS profile
echo "Please enter your AWS profile:"
read -r aws_profile

# Read the CSV file
INPUT="load_balancer_metrics.csv"
echo "Reading CSV file $INPUT..."
OLDIFS=$IFS
IFS=','

# Skip the first line (header) within the input redirection
echo "Skipping the header of CSV file..."
{ read -r; while read -r LoadBalancerName Metric Delete Total
do
    echo "Processing load balancer $LoadBalancerName..."
    if [ "$Delete" = "True" ]; then
        echo "Would you like to delete load balancer $LoadBalancerName? [y/N]"
        read -u 1 -r response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            echo "Deleting load balancer $LoadBalancerName..."
            # The actual deletion command depends on your specific setup and the AWS CLI
            # Please replace the following echo with the real AWS command
            lb_arn=$(aws elbv2 describe-load-balancers --names $LoadBalancerName --query 'LoadBalancers[0].LoadBalancerArn' --output text --profile $aws_profile)
            aws elbv2 delete-load-balancer --load-balancer-arn $lb_arn --profile $aws_profile
        fi
    elif [ "$Delete" = "Auto" ]; then
        echo "Automatically deleting load balancer $LoadBalancerName..."
        # The actual deletion command depends on your specific setup and the AWS CLI
        # Please replace the following echo with the real AWS command
            lb_arn=$(aws elbv2 describe-load-balancers --names $LoadBalancerName --query 'LoadBalancers[0].LoadBalancerArn' --output text --profile $aws_profile)
            aws elbv2 delete-load-balancer --load-balancer-arn $lb_arn --profile $aws_profile
    fi
done } < "$INPUT"
IFS=$OLDIFS
