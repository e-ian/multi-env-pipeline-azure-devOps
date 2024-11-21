#!/bin/bash

# Set environment variables first
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
TENANT_ID=$(az account show --query tenantId -o tsv)
SUBSCRIPTION_NAME=$(az account show --query name -o tsv)

# Create Service Principal if not exists and get credentials
echo "Creating service principal..."
SP_CREDS=$(az ad sp create-for-rbac --name "interswitch-sp" --role contributor --scope /subscriptions/$SUBSCRIPTION_ID --sdk-auth)

# Extract SP_ID and other values
SP_ID=$(echo $SP_CREDS | jq -r .clientId)
SP_KEY=$(echo $SP_CREDS | jq -r .clientSecret)

# Get ACR credentials
ACR_NAME="interswitchacr"
ACR_USERNAME=$(az acr credential show -n $ACR_NAME --query "username" -o tsv)
ACR_PASSWORD=$(az acr credential show -n $ACR_NAME --query "passwords[0].value" -o tsv)

# Print variables for verification
echo "Subscription ID: $SUBSCRIPTION_ID"
echo "Tenant ID: $TENANT_ID"
echo "Service Principal ID: $SP_ID"
echo "ACR Username: $ACR_USERNAME"

# Create Variable Groups
echo "Creating variable groups..."
az pipelines variable-group create \
  --name "dev-variables" \
  --variables \
    environment=development \
    acrName=$ACR_NAME \
    aksName=interswitch-dev-aks \
    keyVaultName=interswitch-dev-kv

az pipelines variable-group create \
  --name "staging-variables" \
  --variables \
    environment=staging \
    acrName=$ACR_NAME \
    aksName=interswitch-staging-aks \
    keyVaultName=interswitch-staging-kv

az pipelines variable-group create \
  --name "prod-variables" \
  --variables \
    environment=production \
    acrName=$ACR_NAME \
    aksName=interswitch-prod-aks \
    keyVaultName=interswitch-prod-kv

# Create Service Connections
echo "Creating service connections..."
export AZURE_DEVOPS_EXT_AZURE_RM_SERVICE_PRINCIPAL_KEY="$SP_KEY"

# Then run the command without the credentials parameter
az devops service-endpoint azurerm create \
  --name "Azure-Service-Connection" \
  --azure-rm-service-principal-id "$SP_ID" \
  --azure-rm-subscription-id "$SUBSCRIPTION_ID" \
  --azure-rm-subscription-name "$SUBSCRIPTION_NAME" \
  --azure-rm-tenant-id "$TENANT_ID"

az devops service-endpoint docker registry create \
  --name "ACR-Service-Connection" \
  --url "$ACR_NAME.azurecr.io" \
  --username "$ACR_USERNAME" \
  --password "$ACR_PASSWORD" \
  --project "interswitch"


echo "Script completed!"