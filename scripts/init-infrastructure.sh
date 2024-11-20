#!/bin/bash

# scripts/init-infrastructure.sh

# Variables
RESOURCE_GROUP="interswitch-rg"
LOCATION="eastus"
ENVIRONMENTS=("dev" "staging" "prod")
ACR_NAME="interswitchacr"
AKS_VERSION="1.25.5"

# Create Resource Group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create ACR
az acr create \
  --resource-group $RESOURCE_GROUP \
  --name $ACR_NAME \
  --sku Basic \
  --admin-enabled true

# Store ACR credentials
ACR_USERNAME=$(az acr credential show -n $ACR_NAME --query "username" -o tsv)
ACR_PASSWORD=$(az acr credential show -n $ACR_NAME --query "passwords[0].value" -o tsv)

# Create AKS Clusters and Key Vaults for each environment
for ENV in "${ENVIRONMENTS[@]}"
do
  # Create AKS Cluster
  az aks create \
    --resource-group $RESOURCE_GROUP \
    --name "interswitch-${ENV}-aks" \
    --node-count 3 \
    --enable-addons monitoring \
    --generate-ssh-keys \
    --attach-acr $ACR_NAME \
    --kubernetes-version $AKS_VERSION

  # Create Key Vault
  az keyvault create \
    --name "interswitch-${ENV}-kv" \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION \
    --enable-rbac-authorization true

  # Add sample secrets (replace with actual secrets in production)
  az keyvault secret set \
    --vault-name "interswitch-${ENV}-kv" \
    --name "DbConnection" \
    --value "Server=db-server;Database=interswitch-${ENV};User Id=admin;Password=dummy123!"

  az keyvault secret set \
    --vault-name "interswitch-${ENV}-kv" \
    --name "ApiKey" \
    --value "dummy-api-key-${ENV}"
done

echo "Infrastructure setup complete!"