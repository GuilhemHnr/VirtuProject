#!/bin/bash

set -e

# Define the path to the fullstackapp repository (assuming it is in the current directory)
PROJECT_DIR=./fullstackapp

# Step 1: Cleanup Kubernetes resources
echo "Deleting Kubernetes resources..."

cd "$PROJECT_DIR/kubernetes"

# Delete the frontend, backend, and database deployments
kubectl delete -f frontend.yaml
kubectl delete -f backend.yaml
kubectl delete -f database.yaml

echo "Stopping Minikube..."
minikube stop

#echo "Deleting Minikube's cluster..."
#minikube delete

echo "Cleanup completed successfully!"