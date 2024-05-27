#!/bin/bash

region=${1:-us-east-1}
enviroment=${2:-development}

# Change appType & appName of application
appType="app"
appName="sub-app"

if [ -n "$region" ] && [ -n "$enviroment" ]; then
    aws ssm get-parameters-by-path --region "$region" --path "/$enviroment/common" --with-decryption |  jq -r '.Parameters[]|((.Name|capture(".*/(?<a>.*)").a+"=")+.Value)' > ./.env.aws
    aws ssm get-parameters-by-path --region "$region" --path "/$enviroment/$appType/$appName" --with-decryption |  jq -r '.Parameters[]|((.Name|capture(".*/(?<a>.*)").a+"=")+.Value)' >> ./.env.aws
else
    echo "Input missing. Exiting..."
fi

sh ./scripts/mapEnvVars.sh
