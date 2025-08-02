#!/bin/bash

echo "🐳 GitHub Actions Self-Hosted Runner Setup for ARM Mac"
echo "======================================================"

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker Desktop first."
    exit 1
fi

echo "✅ Docker is running"

# Build the container
echo "🔨 Building ARM64 GitHub Actions runner container..."
docker-compose build

echo "🚀 Starting container..."
docker-compose up -d

echo ""
echo "📋 Next Steps:"
echo "1. Get a GitHub Personal Access Token:"
echo "   - Go to: https://github.com/settings/tokens"
echo "   - Generate new token (classic)"
echo "   - Select scopes: repo, workflow, admin:org (if for organization)"
echo ""
echo "2. Configure the runner:"
echo "   docker exec -it github-actions-runner bash"
echo "   ./config.sh --url https://github.com/YOUR_USERNAME/YOUR_REPO --token YOUR_TOKEN --name arm64-runner --work _work"
echo ""
echo "3. Start the runner:"
echo "   ./run.sh"
echo ""
echo "🔄 Container Status:"
docker-compose ps

echo ""
echo "📊 To check logs: docker-compose logs -f"
echo "🛠️  To enter container: docker exec -it github-actions-runner bash"
echo "🛑 To stop: docker-compose down"
