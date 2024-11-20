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

Ensure the following Azure resources are provisioned:

```bash
# Example resource naming convention
ACR: interswitch{env}acr
AKS: interswitch-{env}-aks
KeyVault: interswitch-{env}-kv
```

### 2. Azure DevOps Configuration

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
   - Automatic deployment
   - Smoke tests
   - Health checks

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

## Security Considerations

1. **Secret Management**
   - All secrets stored in Azure Key Vault
   - Automatic secret rotation
   - Access audit logging

2. **Access Control**
   - RBAC enforcement
   - Environment segregation
   - Minimal privilege principle

3. **Network Security**
   - Network policies
   - Private endpoints
   - Service mesh (optional)

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