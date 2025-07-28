#!/bin/bash

CONTAINER_NAME=devops-aws-demo
MONITORING_STACK_NAME=monitoring

echo "🚀 Starting deployment..."

# Stop and remove old container if exists
if [ "$(sudo docker ps -aq -f name=$CONTAINER_NAME)" ]; then
    echo "🛑 Stopping and removing old container..."
    sudo docker stop $CONTAINER_NAME
    sudo docker rm $CONTAINER_NAME
fi

# Pull latest image
echo "📦 Pulling latest image from Docker Hub..."
sudo docker pull zajaczek01/devops-aws-demo:latest

# Run new container
echo "▶️ Starting new container..."
sudo docker run -d --name $CONTAINER_NAME -p 5000:5000 zajaczek01/devops-aws-demo:latest

# Wait for app to start
echo "⏳ Waiting for application to start..."
sleep 10

# Health check
echo "🔍 Performing health check..."
if curl -f http://localhost:5000/health > /dev/null 2>&1; then
    echo "✅ Application is healthy!"
else
    echo "❌ Application health check failed!"
    exit 1
fi

# Check if monitoring stack should be deployed
if [ "$DEPLOY_MONITORING" = "true" ]; then
    echo "📊 Setting up monitoring stack..."
    
    # Create monitoring directory if it doesn't exist
    mkdir -p ~/monitoring
    
    # Copy monitoring files
    cp -r ~/devops-aws-demo/monitoring/* ~/monitoring/
    
    # Start monitoring stack
    cd ~/monitoring
    docker-compose down 2>/dev/null
    docker-compose up -d
    
    echo "✅ Monitoring stack deployed!"
    echo "📊 Grafana: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):3000"
    echo "📈 Prometheus: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):9090"
fi

echo "🎯 Deployment complete! App is available on port 5000."
echo "📋 Health check: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):5000/health"
echo "📊 Metrics: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):5000/metrics" 