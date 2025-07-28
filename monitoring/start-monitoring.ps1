# Monitoring startup script for Windows
Write-Host "Starting monitoring stack..." -ForegroundColor Green

# Check if Docker is running
try {
    docker info | Out-Null
    Write-Host "Docker is running" -ForegroundColor Green
} catch {
    Write-Host "Docker is not running. Please start Docker first." -ForegroundColor Red
    exit 1
}

# Stop existing containers if running
Write-Host "Stopping existing containers..." -ForegroundColor Yellow
docker-compose down 2>$null

# Start monitoring stack
Write-Host "Starting Prometheus and Grafana..." -ForegroundColor Green
docker-compose up -d

# Wait for services to start
Write-Host "Waiting for services to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Check if services are running
Write-Host "Checking service status..." -ForegroundColor Yellow

try {
    $response = Invoke-WebRequest -Uri "http://localhost:9090" -UseBasicParsing -TimeoutSec 5
    Write-Host "Prometheus is running on http://localhost:9090" -ForegroundColor Green
} catch {
    Write-Host "Prometheus failed to start" -ForegroundColor Red
}

try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing -TimeoutSec 5
    Write-Host "Grafana is running on http://localhost:3000" -ForegroundColor Green
    Write-Host "Grafana login: admin/admin" -ForegroundColor Cyan
} catch {
    Write-Host "Grafana failed to start" -ForegroundColor Red
}

Write-Host ""
Write-Host "Monitoring stack is ready!" -ForegroundColor Green
Write-Host "Prometheus: http://localhost:9090" -ForegroundColor Cyan
Write-Host "Grafana: http://localhost:3000 (admin/admin)" -ForegroundColor Cyan
Write-Host ""
Write-Host "To stop monitoring: docker-compose down" -ForegroundColor Yellow 