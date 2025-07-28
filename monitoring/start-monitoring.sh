#!/bin/bash

# Monitoring startup script
echo "🚀 Starting monitoring stack..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Stop existing containers if running
echo "🛑 Stopping existing containers..."
docker-compose down 2>/dev/null

# Start monitoring stack
echo "📊 Starting Prometheus and Grafana..."
docker-compose up -d

# Wait for services to start
echo "⏳ Waiting for services to start..."
sleep 10

# Check if services are running
echo "🔍 Checking service status..."

if curl -s http://localhost:9090 > /dev/null; then
    echo "✅ Prometheus is running on http://localhost:9090"
else
    echo "❌ Prometheus failed to start"
fi

if curl -s http://localhost:3000 > /dev/null; then
    echo "✅ Grafana is running on http://localhost:3000"
    echo "📋 Grafana login: admin/admin"
else
    echo "❌ Grafana failed to start"
fi

echo ""
echo "🎯 Monitoring stack is ready!"
echo "📊 Prometheus: http://localhost:9090"
echo "📈 Grafana: http://localhost:3000 (admin/admin)"
echo ""
echo "💡 To stop monitoring: docker-compose down" 