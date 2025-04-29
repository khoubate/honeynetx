#!/bin/bash

echo "Running Prowler security assessment..."
mkdir -p ./outputs/prowler

# Correct syntax for Prowler 3.11.3
prowler azure \
  --az-cli-auth \
  -M json \
  -F prowler-report \
  -o ./outputs/prowler

if [ $? -eq 0 ]; then
    echo "Prowler assessment completed. Reports saved to outputs/prowler/"
else
    echo "Prowler assessment failed."
    exit 1
fi