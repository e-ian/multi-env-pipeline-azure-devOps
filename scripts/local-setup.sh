#!/bin/bash
# scripts/local-setup.sh
# set -x

# Check prerequisites
command -v docker >/dev/null 2>&1 || { echo "Docker is required but not installed. Aborting." >&2; exit 1; }
command -v dotnet >/dev/null 2>&1 || { echo ".NET SDK is required but not installed. Aborting." >&2; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "kubectl is required but not installed. Aborting." >&2; exit 1; }
command -v helm >/dev/null 2>&1 || { echo "Helm is required but not installed. Aborting." >&2; exit 1; }

# Build and test
echo "Building and testing application..."
dotnet restore src/Interswitch.Api/Interswitch.Api.csproj
dotnet build src/Interswitch.Api/Interswitch.Api.csproj
dotnet test src/Interswitch.Tests/Interswitch.Tests.csproj

# Build Docker image
echo "Building Docker image..."
docker build -t interswitch-api:local .

# Package Helm chart
echo "Packaging Helm chart..."
helm package charts/application/

# Run locally
echo "Starting application locally..."
docker run -d -p 8080:80 --name interswitch-api interswitch-api:local

echo "Application is running at http://localhost:8080"
echo "Try the health endpoint: curl http://localhost:8080/health"
