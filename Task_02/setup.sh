#!/bin/bash

# -=-=-=-=-=-=-=- PULLING DOCKER IMAGES -=-=-=-=-=-=-=-

echo "Pulling Docker images..."

# List of docker images
images=(
    "mysql:5.7"
    "oaisoftwarealliance/oai-smf:latest"
    "oaisoftwarealliance/oai-nrf:latest"
    "oaisoftwarealliance/oai-smf:latest"
    "oaisoftwarealliance/oai-spgwu-tiny:latest"
)

# Pull images
for image in "${images[@]}"; do
    echo "Pulling $image..."
    docker pull "$image"
    if [ $? -ne 0 ]; then
        echo "Error pulling $image"
        exit 1
    fi
done

echo "All Docker images pulled successfully!"




----------------------------------------
#!/bin/bash

set -e

echo "OAI 5G-NR RF Simulation Automation Script"
echo "=========================================="

# -=-=-=-=-=-=-=- PULLING DOCKER IMAGES -=-=-=-=-=-=-=-
pull_and_tag_images() {
    echo "Pulling Docker images..."
    docker pull mysql:5.7
    docker pull oaisoftwarealliance/oai-amf:latest
    docker pull oaisoftwarealliance/oai-nrf:latest
    docker pull oaisoftwarealliance/oai-smf:latest
    docker pull oaisoftwarealliance/oai-spgwu-tiny:latest
    docker pull oaisoftwarealliance/oai-gnb:develop
    docker pull oaisoftwarealliance/oai-nr-ue:develop

    echo "Re-tagging Docker images..."
    docker image tag oaisoftwarealliance/oai-amf:latest oai-amf:latest
    docker image tag oaisoftwarealliance/oai-nrf:latest oai-nrf:latest
    docker image tag oaisoftwarealliance/oai-smf:latest oai-smf:latest
    docker image tag oaisoftwarealliance/oai-spgwu-tiny:latest oai-spgwu-tiny:latest
    docker image tag oaisoftwarealliance/oai-gnb:develop oai-gnb:develop
    docker image tag oaisoftwarealliance/oai-nr-ue:develop oai-nr-ue:develop
}

# -=-=-=-=-=-=-=- DEPLOY DOCKER CONTAINERS -=-=-=-=-=-=-=-
deploy_containers() {
    echo "Deploying OAI 5G Core Network..."
    cd 5g_rfsimulator
    docker-compose up -d mysql oai-nrf oai-amf oai-smf oai-spgwu oai-ext-dn
    sleep 30  # Wait for container set up

    echo "Deploying OAI gNB in RF simulator mode..."
    docker-compose up -d oai-gnb
    sleep 20  # Wait for container set up

    echo "Deploying OAI NR-UE in RF simulator mode..."
    docker-compose up -d oai-nr-ue
    sleep 20  # Wait for container set up
}

# -=-=-=-=-=-=-=- CHECK CONNECTIVITY -=-=-=-=-=-=-=-
check_connectivity() {
    echo "Checking Internet connectivity from NR-UE container..."
    docker exec -it rfsim5g-oai-nr-ue ping -I oaitun_ue1 -c 10 www.lemonde.fr || {
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