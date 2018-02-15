#!/bin/bash

# ONLY USE FOR FIRST RUN!!!!
# ...on subsequent starts dimply run "docker start bulwark-docker"
docker volume create bulwark-data
docker run -v bulwark-data:/bulwark --name=bulwark-docker -d -p 52544:52544  -p 52543:52543  8eph/bulwark-docker

# run "docker logs bulwark-docker" for container output
# run "docker exec -it bulwark-docker bash" for interactive shell
