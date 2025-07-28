# DevOps AWS Demo

🇬🇧 [English](README.md) | **🇵🇱 Polski**

Ten repozytorium zawiera projekt, który stworzyłem, aby nauczyć się i zademonstrować nowoczesne praktyki DevOps używając AWS, Docker, Terraform i automatyzacji CI/CD. Aplikacja to prosty REST API w Python Flask do zarządzania zadaniami, wdrożony automatycznie na instancjach AWS EC2 z kompleksowym monitoringiem.

---

## Spis treści
- [Przegląd projektu](#przegląd-projektu)
- [Architektura](#architektura)
- [Stack technologiczny](#stack-technologiczny)
- [Rozpoczęcie pracy](#rozpoczęcie-pracy)
- [REST API – Menedżer zadań](#rest-api--menedżer-zadań)
- [System monitoringu](#system-monitoringu)
- [Automatyczne wdrożenie (CI/CD)](#automatyczne-wdrożenie-cicd)
- [Infrastruktura jako kod](#infrastruktura-jako-kod)
- [Skrypty i automatyzacja](#skrypty-i-automatyzacja)
- [Zarządzanie środowiskami](#zarządzanie-środowiskami)
- [Rozwiązywanie problemów](#rozwiązywanie-problemów)
- [Następne kroki](#następne-kroki)
- [Zrzuty ekranu](#zrzuty-ekranu)
- [Autor](#autor)

---

## Przegląd projektu
Ten projekt to praktyczna implementacja kompletnego workflow DevOps. Chciałem połączyć kodowanie, konteneryzację, infrastrukturę jako kod, automatyzację chmury i monitoring w jednym miejscu. Rdzeniem jest API Flask do zarządzania zadaniami, ale prawdziwa wartość leży w automatyzacji, pipeline wdrożenia i kompleksowym systemie monitoringu.

## Architektura
- **Aplikacja Python Flask** działająca w kontenerach Docker
- **Pipeline CI/CD**: GitHub Actions (testy, build, push na Docker Hub, wdrożenie na AWS EC2)
- **Infrastruktura jako kod**: Terraform (VPC, EC2, Security Groups, klucze SSH)
- **Wdrożenie**: AWS EC2 (Ubuntu, Docker) w wielu środowiskach
- **Monitoring**: Prometheus + Grafana + Strukturalne logowanie
- **Automatyzacja**: Własne skrypty do zarządzania wdrożeniem i monitoringiem

![Diagram architektury](diagrams/architecture.png)

## Stack technologiczny
- **Backend**: Python 3.x, Flask
- **Konteneryzacja**: Docker, Docker Compose
- **CI/CD**: GitHub Actions
- **Infrastruktura**: Terraform, AWS (EC2, VPC, IAM)
- **Monitoring**: Prometheus, Grafana, Strukturalne logowanie
- **Testowanie**: pytest

## Rozpoczęcie pracy

### 1. Sklonuj repozytorium
```sh
git clone https://github.com/zajaczek01/devops-aws-demo.git
cd devops-aws-demo
```

### 2. Uruchom lokalnie z Docker
```sh
cd docker
docker-compose up --build
```
Aplikacja będzie dostępna pod adresem [http://localhost:5000/health](http://localhost:5000/health)

### 3. Lokalny setup monitoringu
```sh
cd monitoring
# Windows:
.\start-monitoring.ps1
# Linux/Mac:
./start-monitoring.sh
```

### 4. Pipeline CI/CD
- Testy i build obrazu Docker są automatycznie uruchamiane przez GitHub Actions
- Obraz Docker jest publikowany na Docker Hub: [zajaczek01/devops-aws-demo](https://hub.docker.com/r/zajaczek01/devops-aws-demo)

### 5. Provisioning infrastruktury AWS (Terraform)
```sh
cd terraform
terraform init
terraform apply
```
- To tworzy instancje EC2, Security Groups i klucze SSH dla wszystkich środowisk
- Po zakończeniu będą wyświetlone publiczne adresy IP

---

## REST API – Menedżer zadań

Aplikacja udostępnia kompleksowe REST API do zarządzania zadaniami z możliwościami monitoringu:

### Endpointy
- `GET /tasks` – pobierz wszystkie zadania
- `POST /tasks` – dodaj nowe zadanie (JSON: `{ "title": "Coś do zrobienia" }`)
- `DELETE /tasks/<id>` – usuń zadanie po id
- `PUT /tasks/<id>/toggle` – przełącz status ukończenia zadania
- `GET /health` – rozszerzony health check ze szczegółowym statusem
- `GET /status` – status aplikacji z metrykami
- `GET /metrics` – endpoint metryk Prometheus

### Przykład użycia (z curl):

**Dodaj nowe zadanie:**
```sh
curl -X POST http://localhost:5000/tasks -H "Content-Type: application/json" -d '{"title": "Kup mleko"}'
```

**Pobierz wszystkie zadania:**
```sh
curl http://localhost:5000/tasks
```

**Przełącz ukończenie zadania:**
```sh
curl -X PUT http://localhost:5000/tasks/1/toggle
```

**Sprawdź zdrowie aplikacji:**
```sh
curl http://localhost:5000/health
```

**Zobacz metryki Prometheus:**
```sh
curl http://localhost:5000/metrics
```

---

## System monitoringu

Projekt zawiera kompleksowe rozwiązanie monitoringu z Prometheus, Grafana i strukturalnym logowaniem.

### Komponenty

#### 1. **Metryki Prometheus**
- **Metryki żądań HTTP**: Całkowita liczba żądań, opóźnienia, aktywne żądania
- **Metryki aplikacji**: Liczba zadań, wskaźniki ukończenia
- **Metryki niestandardowe**: Pomiary specyficzne dla biznesu
- **Kolekcja w czasie rzeczywistym**: Metryki zbierane co 10 sekund

#### 2. **Dashboardy Grafana**
- **Prekonfigurowany dashboard**: Gotowe do użycia wizualizacje
- **Monitoring w czasie rzeczywistym**: Live metryki i alerty
- **Niestandardowe panele**: Żądania HTTP, opóźnienia, metryki zadań
- **Dostęp**: http://PUBLIC_IP:3000 (admin/admin)

#### 3. **Strukturalne logowanie**
- **Format JSON**: Logi czytelne dla maszyn z kontekstem
- **Śledzenie żądań**: Automatyczne mierzenie czasu i logowanie błędów
- **Metryki wydajności**: Czasy odpowiedzi i przepustowość
- **Obsługa błędów**: Kompleksowe śledzenie błędów

### Dostępne metryki

| Metryka | Opis | Typ |
|---------|------|-----|
| `http_requests_total` | Całkowita liczba żądań HTTP według metody/endpointu/statusu | Counter |
| `http_request_duration_seconds` | Histogram opóźnień żądań | Histogram |
| `http_requests_active` | Obecnie aktywne żądania | Gauge |
| `tasks_total` | Całkowita liczba zadań | Gauge |
| `tasks_completed` | Liczba ukończonych zadań | Gauge |

### Health checks

#### Rozszerzony endpoint health (`/health`)
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

#### Endpoint status (`/status`)
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

## Automatyczne wdrożenie (CI/CD)

Projekt implementuje kompletny pipeline CI/CD używając GitHub Actions.

### Przepływ pipeline

1. **Push kodu** → Uruchamia GitHub Actions
2. **Testowanie** → Uruchamia suite pytest
3. **Build** → Tworzy obraz Docker
4. **Push** → Uploaduje na Docker Hub
5. **Synchronizacja** → Kopiuje kod na serwery EC2 (SCP)
6. **Wdrożenie** → Uruchamia skrypty wdrożenia
7. **Weryfikacja** → Health checks i setup monitoringu

### Strategia środowisk

| Branch | Środowisko | Tag Docker | Wdrożenie |
|--------|------------|------------|-----------|
| `main` | Production | `latest` | EC2 + EC2 Production |
| `develop` | Staging | `staging` | Staging EC2 |

### Workflowy GitHub Actions

#### Wdrożenie główne (`deploy.yml`)
- **Trigger**: Push na branch `main`
- **Cele**: EC2 + EC2 Production
- **Funkcje**: Pełne wdrożenie monitoringu

#### Wdrożenie produkcyjne (`deploy-prod.yml`)
- **Trigger**: Push na branch `main`  
- **Cele**: EC2 Production
- **Funkcje**: Konfiguracja specyficzna dla produkcji

#### Wdrożenie staging (`deploy-staging.yml`)
- **Trigger**: Push na branch `develop`
- **Cele**: Staging EC2
- **Funkcje**: Środowisko testowe

---

## Infrastruktura jako kod

Projekt używa Terraform do zarządzania infrastrukturą w wielu środowiskach.

### Środowiska

#### Środowisko główne (`terraform/`)
- **Cel**: Development/Testing
- **Komponenty**: EC2, Security Groups, klucze SSH
- **Monitoring**: Prometheus + Grafana

#### Środowisko staging (`environments/staging/`)
- **Cel**: Testy przed produkcją
- **Komponenty**: Staging EC2, Security Groups
- **Monitoring**: Pełny stack monitoringu

#### Środowisko produkcyjne (`environments/production/`)
- **Cel**: Live produkcja
- **Komponenty**: Production EC2, Security Groups
- **Monitoring**: Monitoring produkcyjny

### Security Groups

Wszystkie środowiska zawierają poprawnie skonfigurowane Security Groups z:
- **Port 22**: Dostęp SSH
- **Port 5000**: Aplikacja Flask
- **Port 3000**: Dashboard Grafana
- **Port 9090**: Metryki Prometheus

---

## Skrypty i automatyzacja

Projekt zawiera kompleksowe skrypty automatyzacji do zarządzania wdrożeniem i monitoringiem.

### Skrypty wdrożenia

#### `scripts/deploy.sh`
**Cel**: Główny skrypt wdrożenia z integracją monitoringu
**Funkcje**:
- Zarządzanie kontenerami Docker
- Health checks
- Automatyczne wdrożenie monitoringu
- Konfiguracja specyficzna dla środowiska

```bash
# Użycie
cd ~/devops-aws-demo/scripts
./deploy.sh
```

#### `scripts/setup-monitoring.sh`
**Cel**: Automatyczne wdrożenie stacku monitoringu
**Funkcje**:
- Setup Prometheus + Grafana
- Kopiowanie plików konfiguracyjnych
- Weryfikacja zdrowia serwisów
- Automatyczny startup

```bash
# Użycie
cd ~/devops-aws-demo/scripts
./setup-monitoring.sh
```

### Skrypty zarządzania monitoringiem

#### `scripts/manage-monitoring.sh`
**Cel**: Zarządzanie stackiem monitoringu
**Komendy**:
- `start` - Uruchom stack monitoringu
- `stop` - Zatrzymaj stack monitoringu
- `restart` - Restart stacku monitoringu
- `status` - Sprawdź status monitoringu
- `logs` - Zobacz logi monitoringu
- `update` - Aktualizuj konfigurację monitoringu

```bash
# Użycie
cd ~/devops-aws-demo/scripts
./manage-monitoring.sh start
./manage-monitoring.sh status
./manage-monitoring.sh logs
```

### Zarządzanie Security Groups

#### `scripts/update-security-groups.sh`
**Cel**: Aktualizacja Security Groups dla wszystkich środowisk
**Funkcje**:
- Dodanie portów monitoringu (3000, 9090)
- Aktualizacja wszystkich środowisk na raz
- Integracja z Terraform

```bash
# Użycie
cd devops-aws-demo/scripts
./update-security-groups.sh
```

#### `scripts/fix-security-group.ps1`
**Cel**: Skrypt PowerShell dla aktualizacji Security Groups
**Funkcje**:
- Bezpieczne dodawanie portów bez niszczenia grup
- Integracja z AWS CLI
- Obsługa błędów

```bash
# Użycie
cd devops-aws-demo/scripts
.\fix-security-group.ps1
```

### Skrypty lokalnego rozwoju

#### `monitoring/start-monitoring.sh`
**Cel**: Lokalny startup stacku monitoringu
**Funkcje**:
- Zarządzanie Docker Compose
- Weryfikacja serwisów
- Health checks

#### `monitoring/start-monitoring.ps1`
**Cel**: Wersja PowerShell dla lokalnego monitoringu
**Funkcje**:
- Kompatybilność cross-platform
- Obsługa błędów
- Weryfikacja statusu serwisów

#### `monitoring/test-monitoring.py`
**Cel**: Testowanie systemu monitoringu
**Funkcje**:
- Generowanie obciążenia
- Weryfikacja health checks
- Walidacja metryk
- Testy end-to-end

```bash
# Użycie
cd monitoring
python test-monitoring.py
```

---

## Zarządzanie środowiskami

### Strategia środowisk

Projekt wspiera wiele środowisk z automatycznym wdrożeniem:

#### Środowisko deweloperskie
- **Branch**: `main`
- **Cel**: Aktywny development
- **Wdrożenie**: Manualne lub automatyczne
- **Monitoring**: Pełny stack

#### Środowisko staging  
- **Branch**: `develop`
- **Cel**: Testy przed produkcją
- **Wdrożenie**: Automatyczne po push
- **Monitoring**: Pełny stack

#### Środowisko produkcyjne
- **Branch**: `main`
- **Cel**: Live produkcja
- **Wdrożenie**: Automatyczne po push
- **Monitoring**: Zoptymalizowany dla produkcji

### Zmienne środowiskowe

#### Wymagane GitHub Secrets
```
DOCKERHUB_USERNAME=twoja_nazwa_dockerhub
DOCKERHUB_TOKEN=twoj_token_dockerhub
EC2_HOST=twoj_public_ip_ec2
EC2_USER=ubuntu
EC2_SSH_KEY=twoj_ssh_private_key
EC2_HOST_PROD=twoj_production_ec2_ip
EC2_USER_PROD=ubuntu
EC2_SSH_KEY_PROD=twoj_production_ssh_key
STAGING_HOST=twoj_staging_ec2_ip
STAGING_USER=ubuntu
STAGING_SSH_KEY=twoj_staging_ssh_key
```

---

## Rozwiązywanie problemów

### Częste problemy i rozwiązania

#### 1. Monitoring się nie uruchamia
**Problem**: Błąd wersji Docker Compose
**Rozwiązanie**: Zaktualizuj `monitoring/docker-compose.yml` do wersji `3.3`

#### 2. Problemy z Security Groups
**Problem**: Porty niedostępne
**Rozwiązanie**: Użyj `scripts/fix-security-group.ps1` do dodania portów monitoringu

#### 3. Problemy z synchronizacją Git
**Problem**: Lokalne zmiany blokują aktualizacje
**Rozwiązanie**: Zresetuj lokalne zmiany i pobierz z remote
```bash
git reset --hard HEAD
git pull origin main
```

#### 4. Problemy z dostępem do monitoringu
**Problem**: Nie można uzyskać dostępu do Grafana/Prometheus
**Rozwiązanie**: 
1. Sprawdź reguły Security Group
2. Zweryfikuj czy stack monitoringu działa
3. Sprawdź ustawienia firewalla

### Komendy health check

#### Zdrowie aplikacji
```bash
curl http://PUBLIC_IP:5000/health
curl http://PUBLIC_IP:5000/status
```

#### Zdrowie monitoringu
```bash
curl http://PUBLIC_IP:3000  # Grafana
curl http://PUBLIC_IP:9090  # Prometheus
```

#### Status kontenerów Docker
```bash
docker ps
docker logs devops-aws-demo
```

---

## Następne kroki

### Potencjalne ulepszenia

1. **System alertowania**
   - Skonfiguruj AlertManager dla Prometheus
   - Ustaw powiadomienia email/Slack
   - Zaimplementuj niestandardowe reguły alertów

2. **Integracja z bazą danych**
   - Dodaj wsparcie PostgreSQL/MySQL
   - Zaimplementuj persystencję danych
   - Dodaj monitoring bazy danych

3. **Load balancing**
   - Zaimplementuj AWS ALB
   - Dodaj auto-scaling groups
   - Skonfiguruj health checks

4. **Ulepszenia bezpieczeństwa**
   - Zaimplementuj HTTPS/TLS
   - Dodaj authentication/authorization
   - Skonfiguruj AWS WAF

5. **Zaawansowany monitoring**
   - Dodaj APM (Application Performance Monitoring)
   - Zaimplementuj distributed tracing
   - Dodaj niestandardowe metryki biznesowe

6. **Backup i recovery**
   - Zaimplementuj automatyczne backupy
   - Dodaj procedury disaster recovery
   - Skonfiguruj polityki retencji danych

---

## Zrzuty ekranu

### Zrzuty aplikacji
- [Diagram architektury](diagrams/architecture.png)
- [Instancje AWS](diagrams/aws_instances.png)
- [Security Groups](diagrams/aws_security_groups.png)
- [Obrazy Docker](diagrams/docker_image.png)
- [GitHub Actions](diagrams/github_actions.png)
- [Dashboard monitoringu](diagrams/status_ok.png)

---

## Autor

Ten projekt został stworzony jako ćwiczenie edukacyjne do demonstracji nowoczesnych praktyk DevOps włączając:
- Infrastrukturę jako kod (Terraform)
- Konteneryzację (Docker)
- Automatyzację CI/CD (GitHub Actions)
- Wdrożenie w chmurze (AWS)
- Monitoring i obserwowalność (Prometheus + Grafana)
- Automatyczne testowanie i wdrożenie

Projekt pokazuje kompletny workflow DevOps od developmentu do produkcji z kompleksowym monitoringiem i automatyzacją.