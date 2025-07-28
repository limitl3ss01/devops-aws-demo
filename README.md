# DevOps AWS Demo

[🇵🇱 Polski](README.pl.md) | 🇬🇧 English

This repository contains a project I built to learn and demonstrate modern DevOps practices using AWS, Docker, Terraform, and CI/CD automation. The application is a simple Python Flask REST API for managing tasks, deployed automatically to an AWS EC2 instance.

---

## Table of Contents
- [Project Overview](#project-overview)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Getting Started](#getting-started)
- [REST API – Task Manager](#rest-api--task-manager)
- [Automated cloud deployment (CI/CD to EC2)](#automated-cloud-deployment-cicd-to-ec2)
- [Quick deployment on EC2](#quick-deployment-on-ec2)
- [Next Steps](#next-steps)
- [Screenshots](#screenshots)
- [Author](#author)

---

## Project Overview
This project is a hands-on implementation of a DevOps workflow. I wanted to combine coding, containerization, infrastructure as code, and cloud automation in one place. The core is a Flask API for managing tasks, but the real value is in the automation and deployment pipeline.

## Architecture
- Python Flask app running in a Docker container
- CI/CD: GitHub Actions (tests, build, push to Docker Hub, deploy to AWS EC2)
- Infrastructure as Code: Terraform (VPC, EC2, Security Group, SSH key)
- Deployment: AWS EC2 (Ubuntu, Docker)
- (Optional) Monitoring: Prometheus + Grafana

![Architecture Diagram](diagrams/architecture.png)

## Tech Stack
- Python 3.x, Flask
- Docker
- GitHub Actions
- Terraform
- AWS (EC2, VPC, IAM)
- Monitoring: Prometheus, Grafana, Structured Logging

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

### 3. CI/CD Pipeline
- Tests and Docker image build are triggered automatically by GitHub Actions
- Docker image is published to Docker Hub: [zajaczek01/devops-aws-demo](https://hub.docker.com/r/zajaczek01/devops-aws-demo)

### 4. AWS Infrastructure Provisioning (Terraform)
```sh
cd terraform
terraform init
terraform apply
```
- This creates an EC2 instance, Security Group, and SSH key
- After completion, the public IP address of the EC2 instance will be displayed

### 5. Deploy the app on EC2
SSH into the EC2 instance:
```sh
ssh -i devops-aws-demo-key ubuntu@PUBLIC_IP_ADDRESS
```
Install Docker and run the app:
```sh
sudo apt update && sudo apt install -y docker.io
sudo docker run -d -p 5000:5000 zajaczek01/devops-aws-demo:latest
```
The app will be available at: `http://PUBLIC_IP_ADDRESS:5000/health`

---

## Monitoring

The application includes comprehensive monitoring with Prometheus metrics, structured logging, and Grafana dashboards.

### Local Monitoring Setup

1. **Start the monitoring stack:**
```sh
cd monitoring
chmod +x start-monitoring.sh
./start-monitoring.sh
```

2. **Test the monitoring setup:**
```sh
python test-monitoring.py
```

3. **Access monitoring tools:**
- **Grafana Dashboard:** http://localhost:3000 (admin/admin)
- **Prometheus:** http://localhost:9090
- **Application Metrics:** http://localhost:5000/metrics

### Monitoring Features

- **Prometheus Metrics:** HTTP requests, latency, task counts
- **Structured Logging:** JSON format with request context
- **Health Checks:** Detailed application status
- **Grafana Dashboard:** Pre-configured dashboard with key metrics
- **Real-time Monitoring:** Live metrics and alerts

### Metrics Available

- `http_requests_total` - Total HTTP requests by method/endpoint/status
- `http_request_duration_seconds` - Request latency histogram
- `http_requests_active` - Currently active requests
- `tasks_total` - Total number of tasks
- `tasks_completed` - Number of completed tasks

---

## REST API – Task Manager

The application exposes a simple REST API for managing tasks (ToDo):

### Endpoints
- `GET /tasks` – get all tasks
- `POST /tasks` – add a new task (JSON: `{ "title": "Something to do" }`)
- `DELETE /tasks/<id>` – delete a task by id
- `PUT /tasks/<id>/toggle` – toggle task completion status
- `GET /health` – health check with detailed status
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

**Delete a task:**
```sh
curl -X DELETE http://localhost:5000/tasks/1
```

### Task model
Each task has the following fields:
- `id` (integer): unique identifier
- `title` (string): task description
- `done` (boolean): completion status

### Example response from `GET /tasks`
```json
[
  {"id": 1, "title": "Buy milk", "done": false},
  {"id": 2, "title": "Write DevOps project documentation", "done": false},
  {"id": 3, "title": "Deploy app to AWS EC2", "done": true}
]
```

---

## Automated cloud deployment (CI/CD to EC2)

This repository includes a GitHub Actions workflow (`.github/workflows/deploy.yml`) that automates deployment to AWS EC2:

- On every push to the `main` branch:
  - Runs tests and builds the Docker image
  - Publishes the image to Docker Hub
  - Connects to my EC2 server via SSH and runs the deployment script (`scripts/deploy.sh`)

**Why?**
I wanted to automate the entire process so that every code change is tested, built, and deployed to the cloud without manual steps. This is how I would approach real-world DevOps automation.

You can monitor the deployment process in the **Actions** tab on GitHub.

---

## Quick deployment on EC2

To update and run the latest version of the app on your EC2 server, use the provided script:

```sh
cd scripts
chmod +x deploy.sh
./deploy.sh
```

This script will:
- Stop and remove the old container (if exists)
- Pull the latest image from Docker Hub
- Start a new container on port 5000

---

## Next Steps
- [ ] Add monitoring (Prometheus, Grafana, CloudWatch)
- [ ] Add more advanced infrastructure (S3, RDS, Load Balancer)
- [ ] Improve security (secrets, HTTPS, port restrictions)
- [ ] Add more API features and tests

---

## Screenshots

Below are some screenshots from the project and DevOps environment:

- **EC2 Instances in AWS:**
  ![EC2 Instances](diagrams/aws_instances.png)

- **Security Group with open port 5000:**
  ![Security Group](diagrams/aws_security_groups.png)

- **Architecture diagram (draw.io):**
  ![Architecture Diagram](diagrams/architecture.png)

---


## Security Practices
- **Private SSH keys are never stored in the repository.** All sensitive credentials are managed via GitHub Secrets or stored securely outside version control.
- **Public keys** are used for provisioning EC2 access and can be safely versioned.
- **Terraform remote state** is stored in S3 with state locking via DynamoDB to prevent concurrent modifications and ensure team safety.
- **Secrets management** leverages GitHub Actions encrypted secrets for all deployment credentials.

## Environment Management
- Each environment (staging, production) has its own isolated infrastructure, state, and deployment pipeline.
- Environment-specific variables are managed via separate `terraform.tfvars` files and backend configurations.
- This separation allows safe testing and validation in staging before promoting changes to production.

## Project Development Strategy
- The project started as a simple Flask API and evolved into a full DevOps automation showcase.
- Infrastructure is managed as code from the start, enabling reproducibility and easy scaling.
- CI/CD pipelines are designed to be extensible, supporting future additions like monitoring, blue/green deployments, or auto-scaling.
- The codebase is modular and ready for further expansion (e.g., adding RDS, S3, Load Balancer, or Kubernetes).


## FAQ
**Q: Why are there separate workflows for staging and production?**
A: This mirrors real-world DevOps practices, where changes are tested in staging before being promoted to production, reducing risk.

**Q: How are secrets and credentials managed?**
A: All sensitive data is stored in GitHub Secrets and never committed to the repository. Only public keys are versioned.

**Q: Can this project be extended to use ECS, EKS, or Kubernetes?**
A: Yes! The modular structure and automation make it easy to add more advanced AWS services or migrate to container orchestration platforms.

**Q: How would you add monitoring or alerting?**
A: By provisioning Prometheus and Grafana (via Terraform or Ansible), exposing app metrics, and integrating with Alertmanager or AWS CloudWatch for notifications.

## Testing Approach
- **Unit tests** are included for the Flask API endpoints and are run automatically in the CI pipeline.
- **Integration tests** can be added to validate the full deployment (e.g., checking `/health` and `/tasks` on staging after deploy).
- **Test coverage** is tracked and can be reported as a CI artifact for quality assurance.
- The project is structured to easily add more advanced tests (e.g., load testing, security scanning) as it evolves.

## Future Directions
- **Migration to ECS/EKS or Kubernetes** for container orchestration and advanced deployment strategies.
- **Blue/Green or Canary Deployments** to enable zero-downtime releases and safer rollouts.
- **Policy enforcement for IaC** using tools like Terraform Sentinel or Open Policy Agent.
- **Automated cost monitoring and optimization** for cloud resources.
- **Self-healing infrastructure** with auto-recovery and health checks.
- **Automated backup and disaster recovery** for critical data and state.

## Challenges and Solutions
- **Managing secrets securely:** Solved by using GitHub Secrets and never storing sensitive data in the repo.
- **Terraform state consistency:** Addressed with remote state in S3 and locking via DynamoDB.
- **Environment drift:** Minimized by enforcing all changes through IaC and CI/CD pipelines.
- **SSH key rotation:** Designed the system to allow easy key updates without downtime.
- **Pipeline reliability:** Added clear error handling and logging in deployment scripts and workflows.

## Security Architecture
- **Network segmentation:** Each environment uses its own VPC and Security Groups, restricting access to only necessary ports and sources.
- **Principle of least privilege:** IAM roles and policies are scoped to the minimum required for each component.
- **Auditability:** All infrastructure changes are tracked via Git and Terraform state, enabling full traceability.
- **No hardcoded credentials:** All secrets are injected at runtime via secure channels.
- **Regular key rotation and review:** SSH keys and secrets are rotated and reviewed as part of the deployment process.

## Code Review & Pull Request Workflow
- All changes are introduced via Pull Requests (PRs) to ensure code quality and enable peer review.
- PRs trigger CI pipelines for tests, linting, and Terraform plan previews before merging.
- Reviewers check for security, maintainability, and adherence to best practices.
- Only after successful review and passing all checks are changes merged to `develop` (staging) or `main` (production).

## Documentation & Onboarding
- The repository includes comprehensive documentation for setup, deployment, and troubleshooting.
- All scripts, workflows, and infrastructure components are described with clear usage instructions.
- New team members can onboard quickly thanks to the structured README, code comments, and example configurations.
- Diagrams and architecture overviews help visualize the system and speed up understanding.

## DevOps Automation in Daily Work
- Routine tasks (deployment, infrastructure changes, secret rotation) are fully automated via CI/CD and IaC.
- Manual interventions are minimized, reducing risk and freeing up time for innovation.
- Automated notifications (e.g., via GitHub Actions) keep the team informed about deployments and failures.
- The project is designed to be extended with further automation (e.g., auto-scaling, self-healing, scheduled backups).

## Cost Management & Optimization
- Infrastructure is provisioned on-demand and can be destroyed when not needed (e.g., ephemeral staging environments).
- Resource types and sizes are chosen for cost-effectiveness (e.g., t3.micro for EC2 in non-production).
- Terraform outputs and tagging enable easy tracking of resource usage and cost allocation.
- Future plans include automated cost monitoring and alerts for budget thresholds.

## Team Collaboration & Communication
- The project structure and workflows are designed for team use, supporting multiple contributors and parallel workstreams.
- Remote state and locking prevent conflicts and ensure safe collaboration on infrastructure.
- Clear commit messages, PR templates, and code review guidelines foster effective communication.
- The project can be easily integrated with team chat tools (Slack, Teams) for deployment notifications and incident response.


---
## Author
zajaczek01 (limitl3ss01)

