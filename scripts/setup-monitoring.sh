#!/bin/bash

# Automatic monitoring setup script
# This script is called after deployment to ensure monitoring is running

echo "🔧 Setting up monitoring stack..."

# Check if monitoring directory exists
if [ ! -d "~/monitoring" ]; then
    echo "📁 Creating monitoring directory..."
    mkdir -p ~/monitoring
fi

# Copy monitoring files
echo "📋 Copying monitoring configuration..."
cp -r ~/devops-aws-demo/monitoring/* ~/monitoring/

# Start monitoring stack
echo "🚀 Starting monitoring stack..."
cd ~/monitoring
docker-compose down 2>/dev/null
docker-compose up -d

# Wait for services to start
echo "⏳ Waiting for monitoring services to start..."
sleep 15

# Check if monitoring is running
echo "🔍 Checking monitoring status..."
if curl -f http://localhost:3000 > /dev/null 2>&1; then
    echo "✅ Grafana is running"
else
    echo "❌ Grafana failed to start"
fi

if curl -f http://localhost:9090 > /dev/null 2>&1; then
    echo "✅ Prometheus is running"
else
    echo "❌ Prometheus failed to start"
fi

echo ""
echo "🎯 Monitoring setup completed!"
echo "📊 Grafana: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):3000"
echo "📈 Prometheus: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):9090" 