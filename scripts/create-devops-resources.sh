#!/bin/bash

# scripts/create-devops-resources.sh

# Create Variable Groups
az pipelines variable-group create \
  --name "dev-variables" \
  --variables \
    environment=development \
    acrName=interswitchacr \
    aksName=interswitch-dev-aks \
    keyVaultName=interswitch-dev-kv

az pipelines variable-group create \
  --name "staging-variables" \
  --variables \
    environment=staging \
    acrName=interswitchacr \
    aksName=interswitch-staging-aks \
    keyVaultName=interswitch-staging-kv

az pipelines variable-group create \
  --name "prod-variables" \
  --variables \
    environment=production \
    acrName=interswitchacr \
    aksName=interswitch-prod-aks \
    keyVaultName=interswitch-prod-kv

# Create Service Connections
az devops service-endpoint azurerm create \
  --name "Azure-Service-Connection" \
  --azure-rm-service-principal-id "$SP_ID" \
  --azure-rm-subscription-id "$SUBSCRIPTION_ID" \
  --azure-rm-subscription-name "$SUBSCRIPTION_NAME" \
  --azure-rm-tenant-id "$TENANT_ID"

az devops service-endpoint docker-registry create \
  --name "ACR-Service-Connection" \
  --docker-registry "$ACR_NAME.azurecr.io" \
  --docker-username "$ACR_USERNAME" \
  --docker-password "$ACR_PASSWORD"
