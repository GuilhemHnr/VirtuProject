#!/bin/bash

set -e

PROJECT_DIR=~/M2_Virtualization/PROJECT/VirtuProject/Task_01/fullstackapp

echo "Deleting Kubernetes resources..."

cd "$PROJECT_DIR/kubernetes"

kubectl delete -f frontend.yaml
kubectl delete -f backend.yaml
kubectl delete -f database.yaml

echo "Stopping Minikube..."
minikube stop

echo "Deleting Minikube's cluster..."
minikube delete

echo "Cleanup completed successfully!"