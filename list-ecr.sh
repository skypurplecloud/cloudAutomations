#!/bin/bash

# List ECR repositories
repository_names=$(aws --profile [add profile] --region us-east-1 ecr describe-repositories --query "repositories[?contains(repositoryName, '[add prefix]')].repositoryName" --output text)

# Check if any matching repositories are found
if [[ -z $repository_names ]]; then
  echo "No matching repositories found."
  exit 0
fi

# Display the list of matching repositories
echo "The following repositories were found:"
echo "$repository_names"
#
# Prompt for confirmation to proceed
# read -rp "Do you want to proceed with deletion? (yes/no): " confirm
# if [[ $confirm != "yes" ]]; then
#   echo "Deletion aborted."
#   exit 0
# fi

# Delete the repositories
# deleted_repositories=0
# for repository_name in $repository_names; do
#   echo "Deleting repository: $repository_name"
#   aws --profile [add-profile] --region us-east-1 ecr delete-repository --repository-name "$repository_name" --force
#   deleted_repositories=$((deleted_repositories + 1))
# done

# echo "Deleted $deleted_repositories repositories."
