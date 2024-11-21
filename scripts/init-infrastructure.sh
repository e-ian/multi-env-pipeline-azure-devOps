#!/bin/bash

# Variables
RESOURCE_GROUP="interswitch-rg"
LOCATION="eastus"
ENVIRONMENTS=("dev" "staging" "prod")
ACR_NAME="interswitchacr"
AKS_VERSION="1.31.1"

# Check if Resource Group exists
if ! az group show --name $RESOURCE_GROUP &>/dev/null; then
    az group create --name $RESOURCE_GROUP --location $LOCATION
fi

# Check if ACR exists
if ! az acr show --resource-group $RESOURCE_GROUP --name $ACR_NAME &>/dev/null; then
    az acr create \
        --resource-group $RESOURCE_GROUP \
        --name $ACR_NAME \
        --sku Basic \
        --admin-enabled true
fi

# Store ACR credentials
ACR_USERNAME=$(az acr credential show -n $ACR_NAME --query "username" -o tsv)
ACR_PASSWORD=$(az acr credential show -n $ACR_NAME --query "passwords[0].value" -o tsv)

# Create AKS Clusters and Key Vaults for each environment
for ENV in "${ENVIRONMENTS[@]}"
do
    # Check if AKS cluster exists
    if ! az aks show --resource-group $RESOURCE_GROUP --name "interswitch-${ENV}-aks" &>/dev/null; then
        az aks create \
            --resource-group $RESOURCE_GROUP \
            --name "interswitch-${ENV}-aks" \
            --node-count 1 \
            --node-vm-size "Standard_B2s"\
            --enable-addons monitoring \
            --generate-ssh-keys \
            --attach-acr $ACR_NAME \
            --kubernetes-version $AKS_VERSION
    fi

    # Check if Key Vault exists
    if ! az keyvault show --name "interswitch-${ENV}-kv" &>/dev/null; then
        az keyvault create \
            --name "interswitch-${ENV}-kv" \
            --resource-group $RESOURCE_GROUP \
            --location $LOCATION \
            --enable-rbac-authorization true
    fi

    # Check and set secrets only if they don't exist
    if ! az keyvault secret show --vault-name "interswitch-${ENV}-kv" --name "DbConnection" &>/dev/null; then
        az keyvault secret set \
            --vault-name "interswitch-${ENV}-kv" \
            --name "DbConnection" \
            --value "Server=db-server;Database=interswitch-${ENV};User Id=admin;Password=dummy123!"
    fi

    if ! az keyvault secret show --vault-name "interswitch-${ENV}-kv" --name "ApiKey" &>/dev/null; then
        az keyvault secret set \
            --vault-name "interswitch-${ENV}-kv" \
            --name "ApiKey" \
            --value "dummy-api-key-${ENV}"
    fi
done

echo "Infrastructure setup complete!"


az quota create --resource-type "virtualMachines" --location "eastus" --subscription "a08c9f90-b45a-44c9-b945-fffe18ddfad0"