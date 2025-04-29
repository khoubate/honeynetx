#!/bin/bash

# Azure Login Script

echo "Logging in to Azure..."
az login

if [ $? -eq 0 ]; then
    echo "Azure login successful!"
    
    # List available subscriptions
    echo "Available subscriptions:"
    az account list --output table
    
    # Prompt to set subscription
    read -p "Enter Subscription ID to use (or press Enter to skip): " sub_id
    if [ ! -z "$sub_id" ]; then
        az account set --subscription "$sub_id"
        echo "Subscription set to $sub_id"
    fi
else
    echo "Azure login failed. Please check your credentials and try again."
    exit 1
fi