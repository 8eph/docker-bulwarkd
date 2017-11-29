#!/bin/bash
#
# Configure broken host machine to run correctly
#
set -ex

STAK_IMAGE=${STAK_IMAGE:-squbs/straks-node}

#memtotal=$(grep ^MemTotal /proc/meminfo | awk '{print int($2/1024) }')

# Only do swap hack if needed
#if [ $memtotal -lt 2048 -a $(swapon -s | wc -l) -lt 2 ]; then
#    sudo fallocate -l 2048M /swap || sudo dd if=/dev/zero of=/swap bs=1M count=2048
#    sudo mkswap /swap
#    grep -q "^/swap" /etc/fstab || sudo echo "/swap swap swap defaults 0 0" >> /etc/fstab
#    sudo swapon -a
#fi

#free -m

curl -fsSL get.docker.com -o /tmp/get-docker.sh
sh /tmp/get-docker.sh

#try to add user to group
puser=$(whoami)
sudo usermod -aG docker $puser

newgrp docker

# Always clean-up, but fail successfully
docker kill straks-node 2>/dev/null || true
docker rm straks-node 2>/dev/null || true
stop docker-straks-node 2>/dev/null || true

# Always pull remote images to avoid caching issues
if [ -z "${STAK_IMAGE##*/*}" ]; then
    docker pull $STAK_IMAGE
fi

# Initialize the data container
docker volume create --name=straks-data
docker run -v straks-data:/straks --rm $STAK_IMAGE straks_init

# Start straks-node via systemd and docker
sudo sh -c 'curl https://raw.githubusercontent.com/straks/straks-node/master/init/docker-straks-node.service > /etc/systemd/system/docker-straks-node.service' 
sudo systemctl enable docker-straks-node.service

set +ex
echo "Resulting straks.conf:"
docker run -v straks-data:/straks --rm $STAK_IMAGE cat /straks/.straks/straks.conf
