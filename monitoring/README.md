# Monitoring

W tym katalogu znajduje się konfiguracja Prometheus i Grafana dla monitoringu aplikacji Flask.

## Komponenty monitoringu

### 1. Aplikacja Flask z metrykami
- **Endpoint `/metrics`** - eksportuje metryki Prometheus
- **Endpoint `/health`** - sprawdzenie stanu aplikacji
- **Endpoint `/status`** - szczegółowe informacje o aplikacji
- **Strukturalne logowanie** - JSON format z kontekstem

### 2. Metryki Prometheus
- `http_requests_total` - liczba żądań HTTP
- `http_request_duration_seconds` - czas odpowiedzi
- `http_requests_active` - aktywne żądania
- `tasks_total` - całkowita liczba zadań
- `tasks_completed` - liczba ukończonych zadań

### 3. Prometheus
- Scrapuje metryki z aplikacji Flask
- Przechowuje dane historyczne
- Dostępny na porcie 9090

### 4. Grafana
- Dashboard do wizualizacji metryk
- Dostępny na porcie 3000
- Login: admin/admin

## Uruchomienie monitoringu

### Opcja 1: Docker Compose
```bash
cd monitoring
docker-compose up -d
```

### Opcja 2: Ręczne uruchomienie

#### Prometheus
```bash
docker run -d \
  --name prometheus \
  -p 9090:9090 \
  -v $(pwd)/prometheus.yml:/etc/prometheus/prometheus.yml \
  prom/prometheus
```

#### Grafana
```bash
docker run -d \
  --name grafana \
  -p 3000:3000 \
  -e GF_SECURITY_ADMIN_USER=admin \
  -e GF_SECURITY_ADMIN_PASSWORD=admin \
  grafana/grafana
```

## Konfiguracja Grafana

1. Otwórz http://localhost:3000
2. Zaloguj się (admin/admin)
3. Dodaj źródło danych Prometheus:
   - URL: http://prometheus:9090
   - Access: Server (default)
4. Zaimportuj dashboard z pliku `grafana-dashboard.json`

## Endpointy aplikacji

### `/health`
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

### `/metrics`
```
# HELP http_requests_total Total HTTP requests
# TYPE http_requests_total counter
http_requests_total{method="GET",endpoint="get_tasks",status="200"} 10
```

### `/status`
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

## Nowe endpointy

### `PUT /tasks/<id>/toggle`
Przełącza status ukończenia zadania.

## Logowanie

Aplikacja używa strukturalnego logowania w formacie JSON:
```json
{
  "timestamp": "2024-01-01T12:00:00",
  "level": "INFO",
  "message": "Request started",
  "method": "GET",
  "endpoint": "get_tasks",
  "path": "/tasks",
  "remote_addr": "127.0.0.1"
}
```

## Alerty (do implementacji)

Można dodać alerty dla:
- Wysokiego czasu odpowiedzi (> 1s)
- Dużej liczby błędów 5xx
- Braku odpowiedzi aplikacji
- Wysokiego użycia pamięci

## Monitoring w produkcji

Dla środowiska produkcyjnego należy:
1. Skonfigurować AlertManager
2. Dodać alerty
3. Skonfigurować retention policy
4. Dodać monitoring systemu (CPU, RAM, disk)
5. Skonfigurować backup metryk 