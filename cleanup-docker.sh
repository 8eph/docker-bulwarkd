#!/bin/bash

docker ps -a | grep "straks-node" | awk '{print $3}' | xargs docker rmi
docker images | grep "straks-node" | awk '{print $1}' | xargs docker rm
docker volume rm straks-data
