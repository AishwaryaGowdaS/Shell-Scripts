#!/bin/bash

region=${1:-us-east-2}

# Before uploading to new region Get all data from another region u want to replicate
# aws dynamodb list-tables --region "$region" > ./dynamoDbTables.json

json=$(cat ./dynamoDbTables.json)

# Loop through each object in the array and upload the parameter to Parameter Store using the AWS CLI
for table_name in $(echo "$json" | jq -c '.TableNames[]'); do
  table_name=$(echo "$table_name" | tr -d '"')

  aws dynamodb create-table \
    --table-name "$table_name" \
    --attribute-definitions AttributeName=PK,AttributeType=S AttributeName=SK,AttributeType=S \
    --key-schema AttributeName=PK,KeyType=HASH AttributeName=SK,KeyType=RANGE \
    --billing-mode PAY_PER_REQUEST \
    --region "$region"

  # Enabling Point in time recovery
#  aws dynamodb update-continuous-backups \
#    --table-name "$table_name" \
#    --point-in-time-recovery-specification PointInTimeRecoveryEnabled=False \
#    --region "$region"
#
#  aws dynamodb update-continuous-backups \
#    --table-name "$table_name" \
#    --point-in-time-recovery-specification PointInTimeRecoveryEnabled=True \
#    --region "$region"

  # Output message indicating table was created
  echo "Table $table_name created with default PK and SK"
done
