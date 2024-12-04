#!/bin/bash

set -e

# Define the path to the fullstackapp repository (assuming it is in the current directory)
PROJECT_DIR=~/M2_Virtualization/PROJECT/VirtuProject/Task_01/fullstackapp

# Start Minikube with the "docker" driver
echo "Starting Minikube with the Docker driver..."
minikube start --driver=docker --cpus=4 --memory=8192 --delete-on-failure

# -=-=-=-=-=-=-=-=-=-=-=-=- Configure Docker to use Minikube
echo "Configuring Docker to use Minikube..."
eval $(minikube docker-env)

# -=-=-=-=-=-=-=-=-=-=-=-=- Build the Docker images

# Build the backend image
echo "Building the backend image..."
cd "$PROJECT_DIR/backend"
docker build -t backend .

# Build the frontend image
echo "Building the frontend image..."
cd "$PROJECT_DIR/frontend"
docker build -t frontend .

# -=-=-=-=-=-=-=-=-=-=-=-=- Apply YAML files
echo "Deploying Kubernetes resources..."

cd "$PROJECT_DIR/kubernetes"

# Apply the database deployment
echo "Applying database.yaml..."
kubectl apply -f database.yaml

# Apply the backend deployment
echo "Applying backend.yaml..."
kubectl apply -f backend.yaml

# Apply the frontend deployment
echo "Applying frontend.yaml..."
kubectl apply -f frontend.yaml

# -=-=-=-=-=-=-=-=-=-=-=-=- Verify the deployment
echo "Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod --all --timeout=120s

echo "Listing all pods:"
kubectl get pods

echo "Listing all services:"
kubectl get services

# -=-=-=-=-=-=-=-=-=-=-=-=- Expose the frontend service and open it
echo "Exposing the frontend service..."
minikube service react-service

echo "Deployment completed successfully!"