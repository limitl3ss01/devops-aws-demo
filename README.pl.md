# DevOps AWS Demo

🇬🇧 English version [here](README.md)

Projekt demonstracyjny DevOps: automatyczny deployment aplikacji Python (Flask) w chmurze AWS z CI/CD, Infrastructure as Code (Terraform) oraz (opcjonalnie) monitoringiem (Prometheus + Grafana).

---

## Spis treści
- [Opis projektu](#opis-projektu)
- [Architektura](#architektura)
- [Stack technologiczny](#stack-technologiczny)
- [Instrukcja uruchomienia](#instrukcja-uruchomienia)
- [Automatyzacja DevOps](#automatyzacja-devops)
- [Dalsze kroki](#dalsze-kroki)
- [Screeny](#screeny)
- [Autor](#autor)

---

## Opis projektu
Projekt pokazuje kompletny proces DevOps: od kodu aplikacji, przez automatyzację testów, budowanie i publikację obrazu Dockera, provisioning infrastruktury w AWS (Terraform), aż po wdrożenie i uruchomienie aplikacji w chmurze. Idealny do portfolio DevOps!

## Architektura
- Aplikacja Python (Flask) uruchamiana w kontenerze Docker
- CI/CD: GitHub Actions (testy, build, push do Docker Hub)
- Infrastructure as Code: Terraform (VPC, EC2, Security Group, klucz SSH)
- Deployment: AWS EC2 (Ubuntu, Docker)
- Monitoring: (opcjonalnie, do rozbudowy) Prometheus + Grafana

![Diagram architektury](diagrams/architecture.png)

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
Aplikacja będzie dostępna pod adresem [http://localhost:5000/health](http://localhost:5000/health)

### 3. Pipeline CI/CD
- Testy i budowanie obrazu Dockera uruchamiane automatycznie przez GitHub Actions
- Obraz Dockera publikowany do Docker Hub: [zajaczek01/devops-aws-demo](https://hub.docker.com/r/zajaczek01/devops-aws-demo)

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
Zainstaluj Dockera i uruchom aplikację:
```sh
sudo apt update && sudo apt install -y docker.io
sudo docker run -d -p 5000:5000 zajaczek01/devops-aws-demo:latest
```
Aplikacja będzie dostępna pod adresem: `http://PUBLICZNY_ADRES_IP:5000/health`

---

## Automatyzacja DevOps
- Pełny pipeline CI/CD (testy, build, push do Docker Hub)
- Infrastructure as Code (Terraform)
- Deployment aplikacji w chmurze AWS
- Gotowe do rozbudowy: monitoring, automatyczny deployment, Ansible, Prometheus, Grafana

---

## Dalsze kroki
- [ ] Automatyzacja deploymentu na EC2 (user-data, Ansible)
- [ ] Monitoring (Prometheus, Grafana, CloudWatch)
- [ ] Pełna dokumentacja i diagramy
- [ ] Bezpieczeństwo (sekrety, ograniczenie portów)

---

## Screeny

Poniżej przykładowe screeny z działania projektu i środowiska DevOps:

- **Instancje EC2 w AWS:**
  ![EC2 Instances](diagrams/aws_instances.png)

- **Security Group z otwartym portem 5000:**
  ![Security Group](diagrams/aws_security_groups.png)

- **Wynik polecenia `docker ps` na EC2:**
  ![Docker PS](diagrams/docker_ps.png)

- **Wynik polecenia `curl http://localhost:5000/health` na EC2:**
  ![Docker Curl](diagrams/docker_curl.png)

- **Widok aplikacji w przeglądarce:**
  ![Aplikacja w przeglądarce](diagrams/status_ok.png)

- **Workflow GitHub Actions (zielony check):**
  ![GitHub Actions](diagrams/github_actions.png)

- **Obraz na Docker Hub:**
  ![Docker Hub](diagrams/docker_image.png)

- **Diagram architektury (draw.io):**
  ![Diagram architektury](diagrams/architecture.png)

---

## REST API – Task Manager

Aplikacja udostępnia proste REST API do zarządzania zadaniami (ToDo):

### Endpointy
- `GET /tasks` – pobierz wszystkie zadania
- `POST /tasks` – dodaj nowe zadanie (JSON: `{ "title": "Coś do zrobienia" }`)
- `DELETE /tasks/<id>` – usuń zadanie o danym id

### Przykłady użycia (curl):

**Dodaj nowe zadanie:**
```sh
curl -X POST http://localhost:5000/tasks -H "Content-Type: application/json" -d '{"title": "Kupić mleko"}'
```

**Pobierz wszystkie zadania:**
```sh
curl http://localhost:5000/tasks
```

**Usuń zadanie:**
```sh
curl -X DELETE http://localhost:5000/tasks/1
```

### Model zadania
Każde zadanie posiada następujące pola:
- `id` (liczba całkowita): unikalny identyfikator
- `title` (tekst): opis zadania
- `done` (prawda/fałsz): status wykonania

### Przykładowa odpowiedź z `GET /tasks`
```json
[
  {"id": 1, "title": "Buy milk", "done": false},
  {"id": 2, "title": "Write DevOps project documentation", "done": false},
  {"id": 3, "title": "Deploy app to AWS EC2", "done": true}
]
```

---

## Autor
zajaczek01 