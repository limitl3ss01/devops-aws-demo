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
- (Optional: Prometheus, Grafana)

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

## REST API – Task Manager

The application exposes a simple REST API for managing tasks (ToDo):

### Endpoints
- `GET /tasks` – get all tasks
- `POST /tasks` – add a new task (JSON: `{ "title": "Something to do" }`)
- `DELETE /tasks/<id>` – delete a task by id

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

## Author
zajaczek01 (limitl3ss01)

