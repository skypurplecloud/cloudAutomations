#!/bin/bash

# Prompt for AWS CLI SSO profile name
echo "Enter AWS CLI SSO profile name: "
read AWS_PROFILE

# Prompt for policy name
echo "Enter policy name: "
read POLICY_NAME

# Get a list of permission sets
PERMISSION_SETS=$(aws sso-admin list-permission-sets --output text --profile "$AWS_PROFILE" | awk '{print $3}')

# Print the available permission sets
echo "Available permission sets:"
echo "$PERMISSION_SETS"

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

# Add the policy to the specified permission set
aws iam attach-managed-policy-to-permission-set --instance-arn <instance_arn> --managed-policy-arn "$POLICY_ARN" --permission-set-arn <permission_set_arn> --profile "$AWS_PROFILE"

echo "Policy added to permission set."
