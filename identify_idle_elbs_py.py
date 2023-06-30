import boto3
import csv
from datetime import datetime, timedelta

# Prompt for the AWS profile
aws_profile = input("Please enter your AWS profile: ")

# Use the entered profile
boto3.setup_default_session(profile_name=aws_profile)

# Create an EC2 and CloudWatch client
elb = boto3.client('elbv2')
cloudwatch = boto3.client('cloudwatch')

# Get a list of all load balancers
load_balancers = elb.describe_load_balancers()

# Get the current time
now = datetime.now()

# Get the time 90 days ago
start_time = now - timedelta(days=90)

# Create a CSV writer
with open('load_balancer_metrics.csv', 'w', newline='') as file:
    writer = csv.writer(file)
    # Write the header
    writer.writerow(["LoadBalancerName", "Metric", "Total", "Delete"])

    # Iterate over all load balancers
    for lb in load_balancers['LoadBalancers']:
        lb_arn = lb['LoadBalancerArn']
        lb_name = lb['LoadBalancerName']

        print(f'Checking {lb_name}...')

        # Get RequestCount and Bytes metrics for the last 90 days
        for metric_name in ['RequestCount', 'Bytes']:
            response = cloudwatch.get_metric_statistics(
                Namespace='AWS/ApplicationELB',
                MetricName=metric_name,
                Dimensions=[
                    {
                        'Name': 'LoadBalancer',
                        'Value': lb_arn
                    },
                ],
                StartTime=start_time,
                EndTime=now,
                Period=3600 * 24,  # fetch data for each day
                Statistics=['Sum']
            )

            # Check if the sum of the metrics is 0
            total = sum(datapoint['Sum'] for datapoint in response['Datapoints'])
            if total == 0:
                print(f'{lb_name} is idle. Consider removing it.')
                writer.writerow([lb_name, metric_name, total, "false"])
