# Interswitch AKS Deployment Pipeline

This repository contains the infrastructure as code and deployment configurations for Interswitch's .NET Core application running on Azure Kubernetes Service (AKS).

## Repository Structure
```
├── .azure-pipelines/
│   ├── main-pipeline.yml           # Main CI/CD pipeline
│   └── templates/
│       ├── deploy-aks.yml          # AKS deployment template
│       └── security-scan.yml       # Security scanning template
├── src/
│   ├── Interswitch.Api/           # .NET Core application source
│   ├── Interswitch.Core/          # Core business logic
│   └── Interswitch.Tests/         # Unit and integration tests
├── charts/
│   └── application/
│       ├── Chart.yaml             # Helm chart definition
│       ├── values.yaml            # Default values
│       ├── values-dev.yaml        # Development values
│       ├── values-staging.yaml    # Staging values
│       ├── values-prod.yaml       # Production values
│       └── templates/
│           ├── deployment.yaml
│           ├── service.yaml
│           ├── ingress.yaml
│           └── secrets.yaml
├── scripts/
│   ├── init-keyvault.sh          # Key Vault setup
│   └── setup-aks.sh              # AKS cluster setup
├── docs/
│   ├── architecture.md           # Solution architecture
│   ├── pipeline.md              # Pipeline documentation
│   └── deployment.md            # Deployment guide
├── Dockerfile                    # Multi-stage Docker build
├── .gitignore
└── README.md
```

## Prerequisites

- Azure subscription with appropriate permissions
- Azure DevOps organization and project
- Azure Container Registry (ACR)
- Azure Kubernetes Service (AKS) clusters for each environment
- Azure Key Vault instances for each environment

## Environment Setup

### 1. Azure Resources
Setup Azure from the CLI by running the following commands

```bash

   # Login to Azure
   az login

   # Set subscription
   az account set --subscription "Your-Subscription-ID"

   # Make scripts executable
   chmod +x scripts/*.sh

   # Run infrastructure setup
   ./scripts/init-infrastructure.sh
```


Ensure the following Azure resources are provisioned:

```bash
   # Example resource naming convention
   ACR: interswitch{env}acr
   AKS: interswitch-{env}-aks
   KeyVault: interswitch-{env}-kv
```

### 2. Azure DevOps Configuration

Setup Azure Devops for the CLi by running the follwoing commands
```bash
   # Install Azure DevOps CLI extension
   az extension add --name azure-devops

   # Login to Azure DevOps
   az devops login

   # Set organization
   az devops configure --defaults organization=https://dev.azure.com/your-org
```

#### Variable Groups
Create the following variable groups in Azure DevOps:

- `dev-variables`
- `staging-variables`
- `prod-variables`

Each should contain:
```yaml
acrName: interswitch{env}acr
aksName: interswitch-{env}-aks
keyVaultName: interswitch-{env}-kv
```

#### Service Connections
Create service connections for:
- Azure subscription
- Azure Container Registry
- Azure Key Vault

NB: Part of the infrastructure configuration can be done by running the script `init-infrastructure.sh` to configure the infrastructure and the script `create-devops-resources.sh` to create the needed resources. You can also use the Azure portal to configure and create these resources.

### 3. Pipeline Environments
Configure environments in Azure DevOps:
- Development
- Staging (with manual approval)
- Production (with two-person approval)

## Deployment Configuration

### Helm Values Structure

Each environment has its own values file (`values-{env}.yaml`) with the following structure:

```yaml
image:
  repository: interswitchacr.azurecr.io/app
  tag: latest
  pullPolicy: Always

replicaCount: 2

ingress:
  enabled: true
  annotations: {}
  hosts:
    - host: app-dev.interswitch.com
      paths: ["/"]

resources:
  limits:
    cpu: 1
    memory: 1Gi
  requests:
    cpu: 500m
    memory: 512Mi

secrets:
  apiKey: ""  # Injected from Key Vault
  dbConnection: ""  # Injected from Key Vault
```

## Pipeline Execution

The pipeline follows this workflow:

1. **Build Stage**
   - Code build and test
   - Security scanning
   - Docker image creation
   - Helm chart packaging

2. **Development Deployment**
   - To deploy to development, run the commands below using Azure CLI and kubectl

   ```bash
   # Get AKS credentials
   1. az aks get-credentials --resource-group interswitch-rg --name interswitch-dev-aks

   # Create namespace
   2. kubectl create namespace development

   # Deploy using Helm
   3. helm upgrade --install interswitch-api ./charts/application \
   --namespace development \
   --values ./charts/application/values-dev.yaml
   ```
   - To run tests locally in development and ensure they are passing before building the pipeline, run the command. This creates a local build and runs tests

   ```bash
      ./scripts/local-setup.sh
   ```

3. **Staging Deployment**
   - Manual approval required
   - Full integration tests
   - Performance tests

4. **Production Deployment**
   - Two-person approval required
   - Canary deployment
   - Monitoring alerts

## Rollback Procedure

Automatic rollbacks are triggered on deployment failures:

```bash
# Manual rollback if needed
helm rollback interswitch-app [REVISION] -n [NAMESPACE]

# View revision history
helm history interswitch-app -n [NAMESPACE]
```

## Monitoring

### Key Metrics
- Deployment success rate
- Application response times
- Error rates
- Resource utilization

### Azure Monitor Alerts
- Pod health
- Node status
- Application performance
- Security events

The following commands can be used to monitor deployment from the terminal using Kubectl
```bash
   # Check pods
   kubectl get pods -n development

   # Check services
   kubectl get svc -n development

   # View logs
   kubectl logs -f deployment/interswitch-api -n development
```

### Setup Azure DevOps Pipeline
To set up Azure DevOps pipeline from the command line, use the command below

```bash
   # Create pipeline
   az pipelines create --name 'Interswitch-API' \
   --yaml-path '/.azure-pipelines/main-pipeline.yml' \
   --repository 'multi-env-pipeline-azure-devOps' \
   --repository-type 'tfsgit' \
   --branch main
```
and create the directory structure using the command below

```bash
   # Create project structure
   mkdir -p src/{Interswitch.Api,Interswitch.Core,Interswitch.Tests} \
         charts/application/{templates,values} \
         scripts \
         docs \
         .azure-pipelines/templates

   # Copy files
   cp -r * /path/to/your/project/ 
```

Reconnect ACR to AKS when neccessary using
```bash
   az aks update -n myAKSCluster -g myResourceGroup --attach-acr myACR
```

Grant pipleline permission to Key Vault using
```bash
   az role assignment create --role "Key Vault Secrets User" \
  --assignee-object-id $(az ad sp show --id <pipeline-principal-id> --query id -o tsv) \
  --scope $(az keyvault show --name <key-vault-name> --query id -o tsv)
```

If you are having trouble with the Kubernetes connection, then run the following command
```bash
   az aks get-credentials --resource-group interswitch-rg --name interswitch-dev-aks --overwrite-existing
```

## Security Considerations

1. **Secret Management**
   - All secrets stored in Azure Key Vault
   - Automatic secret rotation
   - Access audit logging

2. **Access Control**
   - RBAC(Role Based Access Control) enforcement
   - Environment segregation
   - Minimal privilege principle

3. **Network Security**
   - Network policies
   - Private endpoints

## Contributing

1. Create feature branch from `main`
2. Implement changes
3. Submit pull request
4. Require code review approval
5. Automated tests must pass
6. Merge to `main`

## Support

Contact developer:
- Email: ianemma70@gmail.com