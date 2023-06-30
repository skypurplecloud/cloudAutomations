#!/bin/bash

# Prompt for AWS CLI SSO profile name
echo "Enter AWS CLI SSO profile name: "
read AWS_PROFILE

# Prompt for policy name
echo "Enter new policy name: "
read POLICY_NAME

# Prompt for IAM Instance
echo "Enter IAM instance name: "
read INSTANCE_NAME

# Get a list of permission sets
PERMISSION_SETS=$(aws sso-admin list-permission-sets --instance-arn "$INSTANCE_NAME" --output text --query 'PermissionSets[*].PermissionSetArn' --profile "$AWS_PROFILE")

# Print the available permission sets
# echo "Available permission sets:"
# for permission_set in $PERMISSION_SETS
# do
#  permission_set_name=$(aws sso-admin describe-permission-set --permission-set-arn "$permission_set" --output text --query 'PermissionSet.Name' --profile "$AWS_PROFILE")
#  echo "$permission_set_name ($permission_set)"
# done

# Prompt the user to select a permission set
echo "Enter the permission set name to attach the policy to: "
read PERMISSION_SET_NAME

# Create the IAM policy document
POLICY_DOCUMENT=$(cat <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:BatchWriteItem"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "sns:Publish"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "comprehend:DetectEntities",
                "comprehend:DetectKeyPhrases",
                "comprehend:DetectSentiment",
                "comprehend:DetectSyntax"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:ListBucket"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "lambda:InvokeFunction"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "textract:AnalyzeDocument"
            ],
            "Resource": "*"
        }
    ]
}
EOF
)

# Create the IAM policy
POLICY_ARN=$(aws iam create-policy --policy-name "$POLICY_NAME" --policy-document "$POLICY_DOCUMENT" --output text --query 'Policy.Arn' --profile "$AWS_PROFILE")

# Get the ARN of the selected permission set
PERMISSION_SET_ARN=$(aws sso-admin list-permission-sets --region us-east-1 --instance-arn "$INSTANCE_ARN" --output text --query "PermissionSets[?Name=='$PERMISSION_SET_NAME'].PermissionSetArn" --profile "$AWS_PROFILE")

# Add the policy to the specified permission set
aws iam attach-managed-policy-to-permission-set --instance-arn "$INSTANCE_ARN" --managed-policy-arn "$POLICY_ARN" --permission-set-arn "$PERMISSION_SET_ARN" --profile "$AWS_PROFILE"

echo "Policy added to permission set."
