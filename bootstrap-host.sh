#!/bin/bash
#
# Configure broken host machine to run correctly
#
set -ex

BWK_IMAGE=${BWK_IMAGE:-8eph/bulwark-docker:latest}

curl -fsSL get.docker.com -o /tmp/get-docker.sh
sh /tmp/get-docker.sh

#try to add user to group
puser=$(whoami)
sudo usermod -aG docker $puser

newgrp docker

# Always clean-up, but fail successfully
docker kill bulwark-docker 2>/dev/null || true
docker rm bulwark-docker 2>/dev/null || true
stop docker-bulwark-docker 2>/dev/null || true

# Always pull remote images to avoid caching issues
if [ -z "${BWK_IMAGE##*/*}" ]; then
    docker pull $BWK_IMAGE
fi

# Initialize the data container
docker volume create --name=bulwark-data
docker run -v bulwark-data:/bulwark --rm $BWK_IMAGE bulwark_init

# Start bulwark-docker via systemd and docker
# sudo sh -c 'curl https://raw.githubusercontent.com/bulwark/bulwark-docker/master/init/docker-bulwark-docker.service > /etc/systemd/system/docker-bulwark-docker.service'
# sudo systemctl enable docker-bulwark-docker.service

set +ex
echo "Resulting bulwark.conf:"
docker run -v bulwark-data:/bulwark --rm $BWK_IMAGE cat /bulwark/.bulwark/bulwark.conf
