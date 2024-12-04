#!/bin/bash

PREFIX="rfsim5g-"

# Remove docker containers related to the project
#containers=$(docker ps -a --filter "name=${PREFIX}" --format "{{.ID}}")
#if [ -n "$containers" ]; then
#    docker stop $containers
#    docker rm $containers
#    echo "Containers stopped and removed."
#else
#    echo "Failed removing containers"
#fi

docker-compose -f 5g_rfsimulator/docker-compose.yaml down -v

# Clean docker networks
docker network prune -f
echo "Unused networks pruned."