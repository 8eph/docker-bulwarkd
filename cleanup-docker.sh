#!/bin/bash

docker ps -a | grep "bulwark-docker" | awk '{print $3}' | xargs docker rm
docker images | grep "bulwark-docker" | awk '{print $1}' | xargs docker rm
docker volume rm bulwark-data
