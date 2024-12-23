#!/bin/bash

set -e

echo "OAI 5G-NR RF Simulation Automation Script"
echo "=========================================="

# -=-=-=-=-=-=-=- PULLING DOCKER IMAGES -=-=-=-=-=-=-=-
pull_and_tag_images() {
    echo "Pulling Docker images..."
    docker pull mysql:5.7
    docker pull oaisoftwarealliance/oai-amf:v2.0.0
    docker pull oaisoftwarealliance/oai-smf:v2.0.0
    docker pull oaisoftwarealliance/oai-upf:v2.0.0
    docker pull oaisoftwarealliance/trf-gen-cn5g:focal
    docker pull oaisoftwarealliance/oai-gnb:develop
    docker pull oaisoftwarealliance/oai-nr-ue:develop
}

# -=-=-=-=-=-=-=- DEPLOY DOCKER CONTAINERS -=-=-=-=-=-=-=-
deploy_containers() {
    echo "Deploying OAI 5G Core Network..."
    cd 5g_rfsimulator
    docker-compose up -d mysql oai-amf oai-smf oai-upf oai-ext-dn
    sleep 40  # Wait for container set up
    echo " -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- check containers"
    docker-compose ps -a

    echo "Deploying OAI gNB in RF simulator mode..."
    docker-compose up -d oai-gnb
    sleep 60  # Wait for container set up
    echo " -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- check containers"
    docker-compose ps -a

    echo "Deploying OAI NR-UE in RF simulator mode..."
    docker-compose up -d oai-nr-ue
    sleep 60  # Wait for container set up
    echo " -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- check containers"
    docker-compose ps -a
}

# -=-=-=-=-=-=-=- CHECK CONNECTIVITY -=-=-=-=-=-=-=-
check_connectivity() {
    echo "Checking Internet connectivity from NR-UE container..."
    docker exec -it rfsim5g-oai-nr-ue ping -I oaitun_ue1 -c 2 192.168.72.135 || {
        echo "Ping failed!"
        exit 1
    }
    echo "Ping successful!"
}

# -=-=-=-=-=-=-=- RUN TRAFFIC TEST -=-=-=-=-=-=-=-
run_traffic_test() {
    echo "Starting iperf server inside NR-UE container..."
    docker exec -d rfsim5g-oai-nr-ue iperf -B 12.1.1.2 -u -i 1 -s

    echo "Starting iperf client inside ext-dn container..."
    docker exec rfsim5g-oai-ext-dn iperf -c 12.1.1.2 -u -i 1 -t 20 -b 500K
}

# -=-=-=-=-=-=-=- CLEAN DOCKER CONTAINERS -=-=-=-=-=-=-=-
undeploy_containers() {
    echo "Stopping and removing all containers..."
    cd ci-scripts/yaml_files/5g_rfsimulator
    docker-compose down
}

# -=-=-=-=-=-=-=- MAIN -=-=-=-=-=-=-=-
pull_and_tag_images
deploy_containers
check_connectivity
run_traffic_test

echo "FINISHED"