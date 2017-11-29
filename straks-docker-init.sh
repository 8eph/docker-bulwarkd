#!/bin/bash

# ONLY USE FOR FIRST RUN!!!!
# ...on subsequent starts dimply run "docker start straks-node"
docker volume create straks-data
docker run -v straks-data:/straks --name=straks-node -d -p 7575:7575  -p 7574:7574  squbs/straks-node:1.14.5

# run "docker logs straks-node" for container output
# run "docker exec -it straks-node bash" for interactive shell
