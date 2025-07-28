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

# Always deploy monitoring stack
echo "📊 Setting up monitoring stack..."
chmod +x ~/devops-aws-demo/scripts/setup-monitoring.sh
~/devops-aws-demo/scripts/setup-monitoring.sh

echo "🎯 Deployment complete! App is available on port 5000."
echo "📋 Health check: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):5000/health"
echo "📊 Metrics: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):5000/metrics" 