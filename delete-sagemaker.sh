#!/bin/bash

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

# Prompt the user to confirm deletion
read -p "Are you sure you want to delete these endpoints? (y/n) " confirm_delete

if [[ $confirm_delete =~ ^[Yy]$ ]]; then
    # Delete the endpoints
    echo "Deleting endpoints..."
    echo "$endpoint_list" | xargs -n 1 -I {} aws sagemaker delete-endpoint --profile "$profile_name" --region "$region_name" --endpoint-name {}
    echo "Endpoints deleted."
else
    echo "Endpoints not deleted."
fi
