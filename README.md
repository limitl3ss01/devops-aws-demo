# DevOps AWS Demo

Projekt demonstracyjny DevOps: automatyczny deployment aplikacji Python (Flask) w chmurze AWS z CI/CD, Infrastructure as Code (Terraform) oraz monitoringiem (Prometheus + Grafana).

---

## Spis treści
- [Opis projektu](#opis-projektu)
- [Architektura](#architektura)
- [Stack technologiczny](#stack-technologiczny)
- [Instrukcja uruchomienia](#instrukcja-uruchomienia)
- [Automatyzacja DevOps](#automatyzacja-devops)
- [Dalsze kroki](#dalsze-kroki)
- [Diagramy](#diagramy)
- [Autor](#autor)

---

## Opis projektu
Celem projektu jest pokazanie pełnego procesu DevOps: od kodu aplikacji, przez automatyzację testów, budowania i publikacji obrazu Dockera, provisioning infrastruktury w AWS (Terraform), po wdrożenie i uruchomienie aplikacji w chmurze. Projekt idealny do portfolio DevOps!

## Architektura
- Aplikacja Python (Flask) uruchamiana w kontenerze Docker
- CI/CD: GitHub Actions (testy, build, push do Docker Hub)
- Infrastructure as Code: Terraform (VPC, EC2, Security Group, klucz SSH)
- Deployment: AWS EC2 (Ubuntu, Docker)
- Monitoring: (do rozbudowy) Prometheus + Grafana

```mermaid
graph TD;
  Developer-->|git push|GitHub[GitHub]
  GitHub-->|CI/CD|DockerHub[Docker Hub]
  GitHub-->|Terraform|AWS[AWS EC2]
  DockerHub-->|docker pull|AWS
  AWS-->|Aplikacja Flask (Docker)|User[Użytkownik]
```

## Stack technologiczny
- Python 3.x, Flask
- Docker
- GitHub Actions
- Terraform
- AWS (EC2, VPC, IAM)
- (Opcjonalnie: Prometheus, Grafana)

## Instrukcja uruchomienia

### 1. Klonowanie repozytorium
```sh
git clone https://github.com/zajaczek01/devops-aws-demo.git
cd devops-aws-demo
```

### 2. Uruchomienie lokalnie w Dockerze
```sh
cd docker
docker-compose up --build
```
Aplikacja dostępna na [http://localhost:5000/health](http://localhost:5000/health)

### 3. Pipeline CI/CD
- Testy i budowanie obrazu Dockera uruchamiane automatycznie przez GitHub Actions
- Publikacja obrazu do Docker Hub: [zajaczek01/devops-aws-demo](https://hub.docker.com/r/zajaczek01/devops-aws-demo)

### 4. Provisioning infrastruktury AWS (Terraform)
```sh
cd terraform
terraform init
terraform apply
```
- Tworzy EC2, Security Group, klucz SSH
- Po zakończeniu wyświetli publiczny adres IP EC2

### 5. Wdrożenie aplikacji na EC2
Zaloguj się na EC2:
```sh
ssh -i devops-aws-demo-key ubuntu@PUBLICZNY_ADRES_IP
```
Zainstaluj Docker i uruchom aplikację:
```sh
sudo apt update && sudo apt install -y docker.io
sudo docker run -d -p 5000:5000 zajaczek01/devops-aws-demo:latest
```
Aplikacja dostępna na: `http://PUBLICZNY_ADRES_IP:5000/health`

---

## Automatyzacja DevOps
- Pełny pipeline CI/CD (testy, build, push do Docker Hub)
- Infrastructure as Code (Terraform)
- Deployment aplikacji w chmurze AWS
- Możliwość rozbudowy o monitoring, automatyczny deployment, Ansible, Prometheus, Grafana

---

## Dalsze kroki
- [ ] Automatyzacja deploymentu na EC2 (user-data, Ansible)
- [ ] Monitoring (Prometheus, Grafana, CloudWatch)
- [ ] Pełna dokumentacja i diagramy
- [ ] Bezpieczeństwo (sekrety, ograniczenie portów)

---

## Diagramy
Poniżej przykładowy diagram architektury (Mermaid). Możesz dodać własne diagramy w katalogu `diagrams/`.

---

## Screeny

Poniżej przykładowe screeny z działania projektu oraz środowiska DevOps:

- **Instancje EC2 w AWS:**
  ![EC2 Instances](diagrams/aws_instances.png)

- **Security Group z otwartym portem 5000:**
  ![Security Group](diagrams/aws_security_group.png)

- **Logowanie przez SSH do EC2:**
  ![SSH Login](diagrams/ssh_login.png)

- **Wynik polecenia `docker ps` na EC2:**
  ![Docker PS](diagrams/docker_ps.png)

- **Wynik polecenia `curl http://localhost:5000/health` na EC2:**
  ![Docker Curl](diagrams/docker_curl.png)

- **Widok aplikacji w przeglądarce:**
  ![Aplikacja w przeglądarce](diagrams/browser_health.png)

- **Workflow GitHub Actions (zielony check):**
  ![GitHub Actions](diagrams/github_actions.png)

- **Obraz na Docker Hub:**
  ![Docker Hub](diagrams/docker_hub.png)

- **Diagram architektury (draw.io):**
  ![Diagram architektury](diagrams/devops-aws-demo-architecture-icons.png)

---

## Autor
zajaczek01 