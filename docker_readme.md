# GitHub Actions Self-Hosted Runner with Docker on macOS

This guide walks you through setting up a self-hosted GitHub Actions runner using Docker on macOS (Apple Silicon).

## 📋 Prerequisites

- macOS with Apple Silicon (M1/M2/M3)
- Docker Desktop installed and running
- GitHub repository with admin access
- Basic terminal/command line knowledge

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   GitHub Repo   │───▶│  GitHub Actions  │───▶│ Self-Hosted     │
│   (Workflows)   │    │   (Triggers)     │    │ Runner (Docker) │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                                        │
                                                ┌───────▼────────┐
                                                │ ARM64 Ubuntu   │
                                                │ Container      │
                                                │ + Persistent   │
                                                │   Volume       │
                                                └────────────────┘
```

## 🚀 Quick Start

### Step 1: Clone and Navigate to Repository
```bash
git clone https://github.com/ReddyNextDoor/TC_GHActions.git
cd TC_GHActions
```

### Step 2: Run the Setup Script
```bash
chmod +x setup.sh
./setup.sh
```

### Step 3: Get GitHub Registration Token
1. Go to your repository on GitHub
2. Navigate to **Settings** → **Actions** → **Runners**
3. Click **"New self-hosted runner"**
4. Select **Linux** and **ARM64**
5. Copy the registration token from the configuration command

### Step 4: Configure the Runner
```bash
# Enter the container
docker exec -it github-actions-runner bash

# Configure with your token (replace YOUR_TOKEN)
./config.sh --url https://github.com/YOUR_USERNAME/YOUR_REPO --token YOUR_TOKEN --name arm64-runner --work _work --labels self-hosted,linux,ARM64,a8bc952bca85
```

### Step 5: Start the Runner
```bash
# Inside the container
./run.sh
```

## 📁 Repository Structure

```
TC_GHActions/
├── docker_readme.md          # This guide
├── Dockerfile                # ARM64 Ubuntu + GitHub Actions Runner
├── docker-compose.yml        # Container orchestration
├── entrypoint.sh             # Container startup script
├── setup.sh                  # Automated setup script
├── .github/workflows/        # GitHub Actions workflows
│   ├── template-deploy.yml   # Reusable workflow template
│   ├── alpha-deploy.yml      # Alpha environment workflow
│   ├── beta-deploy.yml       # Beta environment workflow
│   ├── charlie-deploy.yml    # Charlie environment workflow
│   └── delta-deploy.yml      # Delta environment workflow
└── test_db/                  # Environment configurations
    ├── alpha/config.yml
    ├── beta/config.yml
    ├── charlie/config.yml
    └── delta/config.yml
```

## 🔧 Detailed Setup Instructions

### 1. Build and Start Container

```bash
# Build the ARM64 container
docker-compose build

# Start the container
docker-compose up -d

# Verify container is running
docker-compose ps
```

### 2. Get GitHub Registration Token

**Important:** You cannot use personal access tokens. You need a registration token from GitHub's UI.

1. **Navigate to Repository Settings:**
   ```
   https://github.com/YOUR_USERNAME/YOUR_REPO/settings/actions/runners
   ```

2. **Click "New self-hosted runner"**

3. **Select Platform:**
   - Operating System: **Linux**
   - Architecture: **ARM64**

4. **Copy the Registration Token:**
   GitHub will show a command like:
   ```bash
   ./config.sh --url https://github.com/YOUR_USERNAME/YOUR_REPO --token AXXXXXXXXXXXXX
   ```
   Copy the token that starts with `A`.

### 3. Configure the Runner

```bash
# Enter the container
docker exec -it github-actions-runner bash

# Configure the runner (replace YOUR_TOKEN and YOUR_REPO)
./config.sh \
  --url https://github.com/YOUR_USERNAME/YOUR_REPO \
  --token YOUR_REGISTRATION_TOKEN \
  --name arm64-runner \
  --work _work \
  --labels self-hosted,linux,ARM64,a8bc952bca85

# Start the runner
./run.sh
```

### 4. Verify Runner Registration

1. Go back to **Settings** → **Actions** → **Runners**
2. You should see your runner listed as **"Online"**
3. Labels should show: `self-hosted`, `linux`, `ARM64`, `a8bc952bca85`

## 🏃‍♂️ Running the Demo Workflows

### Test Individual Environment Deployment

1. **Modify a config file:**
   ```bash
   echo "version: 1.1.0" >> test_db/alpha/config.yml
   git add test_db/alpha/config.yml
   git commit -m "Update alpha config"
   git push origin main
   ```

2. **Watch the workflow:**
   - Go to **Actions** tab in GitHub
   - Only the **Alpha Deploy** workflow should trigger
   - Build job runs on GitHub-hosted runner
   - Deploy job runs on your self-hosted runner

### Test Multiple Environment Deployment

```bash
# Update multiple environments
echo "version: 1.2.0" >> test_db/beta/config.yml
echo "version: 1.3.0" >> test_db/charlie/config.yml
git add test_db/beta test_db/charlie
git commit -m "Update beta and charlie configs"
git push origin main
```

**Result:** Both Beta and Charlie workflows run in parallel, demonstrating environment isolation.

## 🛠️ Container Management

### Start/Stop Container
```bash
# Start
docker-compose up -d

# Stop
docker-compose down

# View logs
docker-compose logs -f

# Restart
docker-compose restart
```

### Access Container
```bash
# Interactive shell
docker exec -it github-actions-runner bash

# Run commands directly
docker exec github-actions-runner ./run.sh --check
```

### Persistent Data

Runner configuration is stored in a Docker volume:
```bash
# View volume
docker volume ls

# Inspect volume
docker volume inspect tc_ghactions_runner-data
```

## 🔍 Troubleshooting

### Container Won't Start
```bash
# Check container status
docker-compose ps

# View container logs
docker-compose logs github-actions-runner

# Rebuild if needed
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Runner Registration Fails

**Error: "404 Not Found"**
- Verify repository URL is correct
- Ensure you're using registration token (starts with `A`), not personal access token
- Check repository permissions

**Error: "Token expired"**
- Registration tokens expire quickly
- Get a new token from GitHub UI
- Reconfigure the runner

### Runner Shows Offline

```bash
# Check runner process
docker exec github-actions-runner ps aux | grep Runner

# Restart runner
docker exec github-actions-runner ./run.sh

# Check runner logs
docker exec github-actions-runner cat _diag/*.log
```

### Workflows Not Triggering

1. **Verify runner labels match workflow requirements:**
   ```yaml
   runs-on: [self-hosted, linux, ARM64, a8bc952bca85]
   ```

2. **Check path triggers:**
   ```yaml
   on:
     push:
       paths:
         - 'test_db/alpha/**'  # Only triggers for alpha changes
   ```

## 🧹 Cleanup

### Remove Runner from GitHub
```bash
# Enter container
docker exec -it github-actions-runner bash

# Remove runner registration
./config.sh remove --token YOUR_REMOVAL_TOKEN
```

### Clean Up Docker Resources
```bash
# Stop and remove containers
docker-compose down

# Remove volumes (⚠️ This deletes runner configuration)
docker-compose down -v

# Remove images
docker rmi tc_ghactions-github-runner
```

## 🎯 Workflow Features Demonstrated

### 1. Environment Isolation
- Changing `test_db/alpha/config.yml` only triggers Alpha workflow
- No cross-contamination between environments

### 2. Matrix Strategy with Concurrency
- Template workflow uses matrix strategy for multiple environments
- Concurrency groups prevent conflicts per environment

### 3. Two-Stage Pipeline
- **Build Stage:** Runs on GitHub-hosted runners (fast, reliable)
- **Deploy Stage:** Runs on self-hosted runner (your infrastructure)

### 4. Artifact Management
- Build stage creates artifacts with metadata
- Deploy stage downloads and deploys artifacts
- Versioning system maintains deployment history

### 5. Persistent Deployments
```bash
# View deployed configurations on runner
docker exec github-actions-runner ls -la /tmp/deployments/
docker exec github-actions-runner cat /tmp/deployments/alpha/config.yml
```

## 📚 Additional Resources

- [GitHub Actions Self-Hosted Runners](https://docs.github.com/en/actions/hosting-your-own-runners)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [GitHub Actions Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with your self-hosted runner
5. Submit a pull request

## 📄 License

This project is open source. Feel free to use and modify as needed.

---

**Happy CI/CD! 🚀**
