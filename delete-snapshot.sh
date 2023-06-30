#!/bin/bash

# Calculate the date 14 days ago in UTC time
date=$(date -u -v-14d +%Y-%m-%dT%H:%M:%SZ)

# Retrieve the list of snapshots
snapshot_ids=$(aws --profile [add profile] rds describe-db-snapshots \
  --region eu-west-1 \
  --query "DBSnapshots[?SnapshotCreateTime<'$date'].DBSnapshotIdentifier" \
  --output json | jq -r '.[] | select(endswith("-lambda-snapshot"))')

# Check if any matching snapshots are found
if [[ -z $snapshot_ids ]]; then
  echo "No matching snapshots found."
  exit 0
fi

# Display the list of matching snapshots
echo "The following snapshots will be deleted:"
echo "$snapshot_ids"

# Prompt for confirmation to proceed
read -rp "Do you want to proceed with deletion? (yes/no): " confirm
if [[ $confirm != "yes" ]]; then
  echo "Deletion aborted."
  exit 0
fi

# Delete the snapshots
deleted_snapshots=0
for snapshot_id in $snapshot_ids; do
  echo "Deleting snapshot: $snapshot_id"
  aws --profile [add profile] rds delete-db-snapshot --db-snapshot-identifier "$snapshot_id" --region [add region]]
  deleted_snapshots=$((deleted_snapshots + 1))
done

echo "Deleted $deleted_snapshots snapshots."
