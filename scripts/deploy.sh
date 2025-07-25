#!/bin/bash

CONTAINER_NAME=devops-aws-demo

# Stop and remove old container if exists
if [ "$(sudo docker ps -aq -f name=$CONTAINER_NAME)" ]; then
    echo "Stopping and removing old container..."
    sudo docker stop $CONTAINER_NAME
    sudo docker rm $CONTAINER_NAME
fi

# Pull latest image
echo "Pulling latest image from Docker Hub..."
sudo docker pull zajaczek01/devops-aws-demo:latest

# Run new container
echo "Starting new container..."
sudo docker run -d --name $CONTAINER_NAME -p 5000:5000 zajaczek01/devops-aws-demo:latest

echo "Deployment complete! App should be available on port 5000." 