# DevOps AWS Demo

[🇵🇱 Polski](README.pl.md) | 🇬🇧 English

This repository contains a project I built to learn and demonstrate modern DevOps practices using AWS, Docker, Terraform, and CI/CD automation. The application is a simple Python Flask REST API for managing tasks, deployed automatically to AWS EC2 instances with comprehensive monitoring.

---

## Table of Contents
- [Project Overview](#project-overview)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Getting Started](#getting-started)
- [REST API – Task Manager](#rest-api--task-manager)
- [Monitoring System](#monitoring-system)
- [Automated Deployment (CI/CD)](#automated-deployment-cicd)
- [Infrastructure as Code](#infrastructure-as-code)
- [Scripts and Automation](#scripts-and-automation)
- [Environment Management](#environment-management)
- [Troubleshooting](#troubleshooting)
- [Next Steps](#next-steps)
- [Screenshots](#screenshots)
- [Author](#author)

---

## Project Overview
This project is a hands-on implementation of a complete DevOps workflow. I wanted to combine coding, containerization, infrastructure as code, cloud automation, and monitoring in one place. The core is a Flask API for managing tasks, but the real value is in the automation, deployment pipeline, and comprehensive monitoring system.

## Architecture
- **Python Flask app** running in Docker containers
- **CI/CD Pipeline**: GitHub Actions (tests, build, push to Docker Hub, deploy to AWS EC2)
- **Infrastructure as Code**: Terraform (VPC, EC2, Security Groups, SSH keys)
- **Deployment**: AWS EC2 (Ubuntu, Docker) across multiple environments
- **Monitoring**: Prometheus + Grafana + Structured Logging
- **Automation**: Custom scripts for deployment and monitoring management

![Architecture Diagram](diagrams/architecture.png)

## Tech Stack
- **Backend**: Python 3.x, Flask
- **Containerization**: Docker, Docker Compose
- **CI/CD**: GitHub Actions
- **Infrastructure**: Terraform, AWS (EC2, VPC, IAM)
- **Monitoring**: Prometheus, Grafana, Structured Logging
- **Testing**: pytest

## Getting Started

### 1. Clone the repository
```sh
git clone https://github.com/zajaczek01/devops-aws-demo.git
cd devops-aws-demo
```

### 2. Run locally with Docker
```sh
cd docker
docker-compose up --build
```
The app will be available at [http://localhost:5000/health](http://localhost:5000/health)

### 3. Local Monitoring Setup
```sh
cd monitoring
# Windows:
.\start-monitoring.ps1
# Linux/Mac:
./start-monitoring.sh
```

### 4. CI/CD Pipeline
- Tests and Docker image build are triggered automatically by GitHub Actions
- Docker image is published to Docker Hub: [zajaczek01/devops-aws-demo](https://hub.docker.com/r/zajaczek01/devops-aws-demo)

### 5. AWS Infrastructure Provisioning (Terraform)
```sh
cd terraform
terraform init
terraform apply
```
- This creates EC2 instances, Security Groups, and SSH keys for all environments
- After completion, the public IP addresses will be displayed

---

## REST API – Task Manager

The application exposes a comprehensive REST API for managing tasks with monitoring capabilities:

### Endpoints
- `GET /tasks` – get all tasks
- `POST /tasks` – add a new task (JSON: `{ "title": "Something to do" }`)
- `DELETE /tasks/<id>` – delete a task by id
- `PUT /tasks/<id>/toggle` – toggle task completion status
- `GET /health` – enhanced health check with detailed status
- `GET /status` – application status with metrics
- `GET /metrics` – Prometheus metrics endpoint

### Example usage (with curl):

**Add a new task:**
```sh
curl -X POST http://localhost:5000/tasks -H "Content-Type: application/json" -d '{"title": "Buy milk"}'
```

**Get all tasks:**
```sh
curl http://localhost:5000/tasks
```

**Toggle task completion:**
```sh
curl -X PUT http://localhost:5000/tasks/1/toggle
```

**Check application health:**
```sh
curl http://localhost:5000/health
```

**View Prometheus metrics:**
```sh
curl http://localhost:5000/metrics
```

---

## Monitoring System

The project includes a comprehensive monitoring solution with Prometheus, Grafana, and structured logging.

### Components

#### 1. **Prometheus Metrics**
- **HTTP Request Metrics**: Total requests, latency, active requests
- **Application Metrics**: Task counts, completion rates
- **Custom Metrics**: Business-specific measurements
- **Real-time Collection**: Metrics scraped every 10 seconds

#### 2. **Grafana Dashboards**
- **Pre-configured Dashboard**: Ready-to-use visualizations
- **Real-time Monitoring**: Live metrics and alerts
- **Custom Panels**: HTTP requests, latency, task metrics
- **Access**: http://PUBLIC_IP:3000 (admin/admin)

#### 3. **Structured Logging**
- **JSON Format**: Machine-readable logs with context
- **Request Tracking**: Automatic timing and error logging
- **Performance Metrics**: Response times and throughput
- **Error Handling**: Comprehensive error tracking

### Metrics Available

| Metric | Description | Type |
|--------|-------------|------|
| `http_requests_total` | Total HTTP requests by method/endpoint/status | Counter |
| `http_request_duration_seconds` | Request latency histogram | Histogram |
| `http_requests_active` | Currently active requests | Gauge |
| `tasks_total` | Total number of tasks | Gauge |
| `tasks_completed` | Number of completed tasks | Gauge |

### Health Checks

#### Enhanced Health Endpoint (`/health`)
```json
{
  "status": "ok",
  "timestamp": "2024-01-01T12:00:00",
  "version": "1.0.0",
  "checks": {
    "database": "ok",
    "memory": "ok", 
    "disk": "ok"
  }
}
```

#### Status Endpoint (`/status`)
```json
{
  "status": "running",
  "timestamp": "2024-01-01T12:00:00",
  "version": "1.0.0",
  "metrics": {
    "total_tasks": 4,
    "completed_tasks": 1,
    "pending_tasks": 3
  }
}
```

---

## Automated Deployment (CI/CD)

The project implements a complete CI/CD pipeline using GitHub Actions.

### Pipeline Flow

1. **Code Push** → Triggers GitHub Actions
2. **Testing** → Runs pytest suite
3. **Build** → Creates Docker image
4. **Push** → Uploads to Docker Hub
5. **Sync** → Copies code to EC2 servers (SCP)
6. **Deploy** → Runs deployment scripts
7. **Verify** → Health checks and monitoring setup

### Environment Strategy

| Branch | Environment | Docker Tag | Deployment |
|--------|-------------|------------|------------|
| `main` | Production | `latest` | EC2 + EC2 Production |
| `develop` | Staging | `staging` | Staging EC2 |

### GitHub Actions Workflows

#### Main Deployment (`deploy.yml`)
- **Trigger**: Push to `main` branch
- **Targets**: EC2 + EC2 Production
- **Features**: Full monitoring deployment

#### Production Deployment (`deploy-prod.yml`)
- **Trigger**: Push to `main` branch  
- **Targets**: EC2 Production
- **Features**: Production-specific configuration

#### Staging Deployment (`deploy-staging.yml`)
- **Trigger**: Push to `develop` branch
- **Targets**: Staging EC2
- **Features**: Testing environment

---

## Infrastructure as Code

The project uses Terraform for infrastructure management across multiple environments.

### Environments

#### Main Environment (`terraform/`)
- **Purpose**: Development/Testing
- **Components**: EC2, Security Groups, SSH Keys
- **Monitoring**: Prometheus + Grafana

#### Staging Environment (`environments/staging/`)
- **Purpose**: Pre-production testing
- **Components**: Staging EC2, Security Groups
- **Monitoring**: Full monitoring stack

#### Production Environment (`environments/production/`)
- **Purpose**: Live production
- **Components**: Production EC2, Security Groups
- **Monitoring**: Production monitoring

### Security Groups

All environments include properly configured Security Groups with:
- **Port 22**: SSH access
- **Port 5000**: Flask application
- **Port 3000**: Grafana dashboard
- **Port 9090**: Prometheus metrics

---

## Scripts and Automation

The project includes comprehensive automation scripts for deployment and monitoring management.

### Deployment Scripts

#### `scripts/deploy.sh`
**Purpose**: Main deployment script with monitoring integration
**Features**:
- Docker container management
- Health checks
- Automatic monitoring deployment
- Environment-specific configuration

```bash
# Usage
cd ~/devops-aws-demo/scripts
./deploy.sh
```

#### `scripts/setup-monitoring.sh`
**Purpose**: Automated monitoring stack deployment
**Features**:
- Prometheus + Grafana setup
- Configuration file copying
- Service health verification
- Automatic startup

```bash
# Usage
cd ~/devops-aws-demo/scripts
./setup-monitoring.sh
```

### Monitoring Management Scripts

#### `scripts/manage-monitoring.sh`
**Purpose**: Monitoring stack management
**Commands**:
- `start` - Start monitoring stack
- `stop` - Stop monitoring stack
- `restart` - Restart monitoring stack
- `status` - Check monitoring status
- `logs` - View monitoring logs
- `update` - Update monitoring configuration

```bash
# Usage
cd ~/devops-aws-demo/scripts
./manage-monitoring.sh start
./manage-monitoring.sh status
./manage-monitoring.sh logs
```

### Security Group Management

#### `scripts/update-security-groups.sh`
**Purpose**: Update Security Groups for all environments
**Features**:
- Add monitoring ports (3000, 9090)
- Update all environments at once
- Terraform integration

```bash
# Usage
cd devops-aws-demo/scripts
./update-security-groups.sh
```

#### `scripts/fix-security-group.ps1`
**Purpose**: Windows PowerShell script for Security Group updates
**Features**:
- Safe port addition without destroying groups
- AWS CLI integration
- Error handling

```bash
# Usage
cd devops-aws-demo/scripts
.\fix-security-group.ps1
```

### Local Development Scripts

#### `monitoring/start-monitoring.sh`
**Purpose**: Local monitoring stack startup
**Features**:
- Docker Compose management
- Service verification
- Health checks

#### `monitoring/start-monitoring.ps1`
**Purpose**: Windows PowerShell version for local monitoring
**Features**:
- Cross-platform compatibility
- Error handling
- Service status verification

#### `monitoring/test-monitoring.py`
**Purpose**: Monitoring system testing
**Features**:
- Load generation
- Health check verification
- Metrics validation
- End-to-end testing

```bash
# Usage
cd monitoring
python test-monitoring.py
```

---

## Environment Management

### Environment Strategy

The project supports multiple environments with automated deployment:

#### Development Environment
- **Branch**: `main`
- **Purpose**: Active development
- **Deployment**: Manual or automated
- **Monitoring**: Full stack

#### Staging Environment  
- **Branch**: `develop`
- **Purpose**: Pre-production testing
- **Deployment**: Automated on push
- **Monitoring**: Full stack

#### Production Environment
- **Branch**: `main`
- **Purpose**: Live production
- **Deployment**: Automated on push
- **Monitoring**: Production-optimized

### Environment Variables

#### Required GitHub Secrets
```
DOCKERHUB_USERNAME=your_dockerhub_username
DOCKERHUB_TOKEN=your_dockerhub_token
EC2_HOST=your_ec2_public_ip
EC2_USER=ubuntu
EC2_SSH_KEY=your_ssh_private_key
EC2_HOST_PROD=your_production_ec2_ip
EC2_USER_PROD=ubuntu
EC2_SSH_KEY_PROD=your_production_ssh_key
STAGING_HOST=your_staging_ec2_ip
STAGING_USER=ubuntu
STAGING_SSH_KEY=your_staging_ssh_key
```

---

## Troubleshooting

### Common Issues and Solutions

#### 1. Monitoring Not Starting
**Problem**: Docker Compose version error
**Solution**: Update `monitoring/docker-compose.yml` to use version `3.3`

#### 2. Security Group Issues
**Problem**: Ports not accessible
**Solution**: Use `scripts/fix-security-group.ps1` to add monitoring ports

#### 3. Git Synchronization Issues
**Problem**: Local changes blocking updates
**Solution**: Reset local changes and pull from remote
```bash
git reset --hard HEAD
git pull origin main
```

#### 4. Monitoring Access Issues
**Problem**: Cannot access Grafana/Prometheus
**Solution**: 
1. Check Security Group rules
2. Verify monitoring stack is running
3. Check firewall settings

### Health Check Commands

#### Application Health
```bash
curl http://PUBLIC_IP:5000/health
curl http://PUBLIC_IP:5000/status
```

#### Monitoring Health
```bash
curl http://PUBLIC_IP:3000  # Grafana
curl http://PUBLIC_IP:9090  # Prometheus
```

#### Docker Container Status
```bash
docker ps
docker logs devops-aws-demo
```

---

## Next Steps

### Potential Enhancements

1. **Alerting System**
   - Configure AlertManager for Prometheus
   - Set up email/Slack notifications
   - Implement custom alert rules

2. **Database Integration**
   - Add PostgreSQL/MySQL support
   - Implement data persistence
   - Add database monitoring

3. **Load Balancing**
   - Implement AWS ALB
   - Add auto-scaling groups
   - Configure health checks

4. **Security Enhancements**
   - Implement HTTPS/TLS
   - Add authentication/authorization
   - Configure AWS WAF

5. **Advanced Monitoring**
   - Add APM (Application Performance Monitoring)
   - Implement distributed tracing
   - Add custom business metrics

6. **Backup and Recovery**
   - Implement automated backups
   - Add disaster recovery procedures
   - Configure data retention policies

---

## Screenshots

### Application Screenshots
- [Architecture Diagram](diagrams/architecture.png)
- [AWS Instances](diagrams/aws_instances.png)
- [Security Groups](diagrams/aws_security_groups.png)
- [Docker Images](diagrams/docker_image.png)
- [GitHub Actions](diagrams/github_actions.png)
- [Monitoring Dashboard](diagrams/status_ok.png)

---

## Author

This project was created as a learning exercise to demonstrate modern DevOps practices including:
- Infrastructure as Code (Terraform)
- Containerization (Docker)
- CI/CD Automation (GitHub Actions)
- Cloud Deployment (AWS)
- Monitoring and Observability (Prometheus + Grafana)
- Automated Testing and Deployment

The project showcases a complete DevOps workflow from development to production with comprehensive monitoring and automation.

