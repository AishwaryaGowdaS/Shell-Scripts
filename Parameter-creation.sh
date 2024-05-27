#!/bin/bash

region=${1:-us-east-2}

# Before uploading to new region Get all data from another region u want to replicate
#aws ssm get-parameters-by-path --region "$region" --path "/" --recursive > ./parameters.json


json=$(cat ./parameters.json)

# Loop through each object in the array and upload the parameter to Parameter Store using the AWS CLI
for obj in $(echo "$json" | jq -c '.Parameters[]'); do
    name=$(echo "$obj" | jq -r '.Name')
    value=$(echo "$obj" | jq -r '.Value')
    aws ssm put-parameter --region "$region" --name "$name" --type "String" --value "$value"
done
