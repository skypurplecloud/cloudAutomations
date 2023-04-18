#!/bin/bash

# this is a simple shell script to assist with the deletion of sagemaker endpoints in bulk from AWS.
# provided by skyPurple Cloud Limited under GNU General Public License (GPL) v3 license.
# 
# contact roy@skypurple.cloud for information on supporting your company's cloud operations.
# 
# skyPurple Cloud - SECURE - OPTIMIZE - AUTOMATE
#
# USAGE:
# login to your account via aws configure sso, or set a profile in your ./aws/credentials file
# recommended to use a very short profile name for ease of execution in this script
# download this script to your local computer, ensure you have AWS CLI v2 installed
# run the following command to make the file executable at your CLI "chmod +x filename.sh"
#

# Prompt for the start of the endpoint names to be deleted
read -p "Enter the start of the endpoint names to be deleted: " endpoint_start

# Prompt for the AWS CLI profile name to use
read -p "Enter the AWS CLI profile name to use: " profile_name

# Prompt for the AWS region to use
read -p "Enter the AWS region to use (e.g., eu-west-1): " region_name

# List the endpoints that match the given start string
endpoint_list=$(aws sagemaker list-endpoints --profile "$profile_name" --region "$region_name" --query "Endpoints[?starts_with(EndpointName,'$endpoint_start')].EndpointName" --output text)

# Print the list of endpoints to the terminal
echo "The following endpoints will be deleted:"
for endpoint_name in $endpoint_list; do
    echo "$endpoint_name"
done
echo

# Prompt the user to select endpoints to delete
read -p "Enter a comma-separated list of endpoint names to delete (or 'all' to delete all): " endpoints_to_delete

if [[ "$endpoints_to_delete" == "all" ]]; then
    # Delete all endpoints
    echo "Deleting all endpoints..."
    for endpoint_name in $endpoint_list; do
        aws sagemaker delete-endpoint --profile "$profile_name" --region "$region_name" --endpoint-name "$endpoint_name"
    done
    echo "All endpoints deleted."
else
    # Delete selected endpoints
    echo "Deleting selected endpoints..."
    for endpoint_name in $(echo "$endpoints_to_delete" | tr ',' ' '); do
        if [[ "$endpoint_list" == *"$endpoint_name"* ]]; then
            aws sagemaker delete-endpoint --profile "$profile_name" --region "$region_name" --endpoint-name "$endpoint_name"
            echo "Endpoint $endpoint_name deleted."
        else
            echo "Endpoint $endpoint_name not found or not selected for deletion."
        fi
    done
    echo "Selected endpoints deleted."
fi
