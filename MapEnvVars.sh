#!/bin/bash

while IFS= read -r line || [ -n "$line" ]; do
    key=$(echo "$line" | cut -d "=" -f 1)
    value=$(echo "$line" | cut -d "=" -f 2-)

    # Looping through env file to get the value
    found=false
    while IFS= read -r line1 || [ -n "$line2" ]; do
      env_key=$(echo "$line1" | cut -d "=" -f 1)
      env_value=$(echo "$line1" | cut -d "=" -f 2-)
      # removing unnecessary \n and spaces
      value=$(echo "$value" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
      if [ "$value" = "$env_key" ]; then
        found=true
        break
      fi
    done < ./.env.aws
    line="${key}=${value}"
    if [ "$found" = true ]; then
      line="${key}=${env_value}"
    fi
    echo "$line"

done < ./.env.template > ./.env
