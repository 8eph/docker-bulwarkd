STRAKS Node For Docker
======================

[![Docker Stars](https://img.shields.io/docker/stars/squbs/straks-node.svg)](https://hub.docker.com/r/squbs/straks-node/)
[![Docker Pulls](https://img.shields.io/docker/pulls/squbs/straks-node.svg)](https://hub.docker.com/r/squbs/straks-node/)
[![ImageLayers](https://images.microbadger.com/badges/image/squbs/straks-node.svg)](https://microbadger.com/#/images/squbs/straks-node)

Docker image that runs a STRAKS node in a container for easy deployment.


Requirements
------------

* Physical machine, cloud instance, or VPS that supports Docker (i.e. [Digital Ocean](https://goo.gl/eWziH7), KVM or XEN based VMs) running Ubuntu 16.04 or later (*not OpenVZ containers!*)
* At least 5 GB to store the block chain files (chain will grow continously)
* At least 1 GB RAM + 2 GB swap file
* Run `sudo usermod -aG docker <user>` and then logout/login or reboot, if you're a new Docker user
* Encrypted wallets will need to be unlocked for staking (see below)


Really Fast Quick Start
-----------------------

One liner for Ubuntu Xenial/Zesty machines with JSON-RPC enabled on localhost and adds systemd service:

    curl https://raw.githubusercontent.com/straks/straks-node/master/bootstrap-host.sh | sh

For Raspberry Pi 2/3:

    curl https://raw.githubusercontent.com/straks/straks-node/master/bootstrap-host-armhf.sh |  sh

You will most likely need to run the above twice, if your user is not part of the Docker group or its a new installation of Docker. Log out and then in again and ensure that user is a member of the docker group (run `id`). User will also need `sudo` permissions.

Use `-H 'Cache-Control: no-cache'` with the curl command to return non-cached data from the web server.

Finally in order to start the node manually run:

    sudo systemctl start docker-straks-node
    

Quick Start
-----------

1. Create a `straks-data` volume to persist the STRAKS blockchain data, should exit immediately.  The `straks-data` container will store the blockchain when the node container is recreated (software upgrade, reboot, etc):

        docker volume create --name=straks-data
        docker run -v straks-data:/straks --name=straks-node -d \
            -p 7575:7575 \
            -p 7574:7574 \
            squbs/straks-node

2. Verify that the container is running and `straks-node` daemon is downloading the blockchain:

        $ docker ps
        CONTAINER ID        IMAGE                         COMMAND             CREATED             STATUS              PORTS                                              NAMES
        ee825ac17747     squbs/straks-node:latest     "straks_oneshot"       2 seconds ago       Up 1 seconds        127.0.0.1:7575->7575/tcp, 0.0.0.0:7574->7574/tcp   straks-node

3. You can then access the daemon's output thanks to the [docker logs command]( https://docs.docker.com/reference/commandline/cli/#logs)

        $ docker logs -f straks-node

4. Install optional init scripts for upstart and systemd located in the `init` directory.


General Commands
----------------

1. Open a bash shell within the running container and issue commands to the daemon:

        $ docker exec -it straks-node bash
        $ straksd getinfo

2. Copy file (e.g. straks.conf) in and out of the container: 
        
        # Copy to your local dir:
        $ docker cp straks-node:/straks/.straks/straks.conf .
        
        # Copy back to the container: 
        $ docker straks.conf straks-node:/straks/.straks/straks.conf 

        # Stop/start the container
        $ docker stop straks-node
        $ docker start straks-node

3. Backup wallet (two approaches): 

        # Approach 1 
        # This will create a human readable file dump (depending on encryption status etc):

        (a) Dump wallet:
            $ docker exec -it  straks-node straksd dumpwallet backup_wallet.dat
        
        (b) Copy to local dir: 
            $ docker cp straks-node:/straks/backup_wallet.dat .


        # Approach 2
        # This will create a binary file:

        (a) Copy dat file to local dir: 
            $ docker cp straks-node:/straks/.straks/wallet.dat backup_wallet.dat

4. Check `straks-node` log file using system `tail -f` command:

        $ docker ps

        # Note the 'COINTAINER ID' for straks-node
        CONTAINER ID        IMAGE                 COMMAND                  CREATED             STATUS              PORTS                                                       NAMES
        ee825ac17747        squbs/straks-node:1.14.5   "docker-entrypoint..."   21 seconds ago      Up 21 seconds       7575/tcp, 0.0.0.0:7574->7574/tcp   straks-node`

        # Run inspect command on container id
        $ docker inspect --format='{{.LogPath}}' ee825ac17747

        # Docker will output location and filename of the container log file:  
        $ /var/lib/docker/containers/ee825ac17747f2abaf627600860697e1213249ab83bb0cf136684dd4a4b7f55d/ee825ac17747f2abaf627600860697e1213249ab83bb0cf136684dd4a4b7f55d-json.log
        
        $ tail -f ee825ac17747f2abaf627600860697e1213249ab83bb0cf136684dd4a4b7f55d-json.log

5. Modify `straks.conf` and/or `wallet.dat` files without `docker cp`:

        $ docker volume inspect straks-data
       
        # output: 
        [
            {
                "CreatedAt": "2017-11-26T16:07:53Z",
                "Driver": "local",
                "Labels": {},
                "Mountpoint": "/var/lib/docker/volumes/straks-data/_data",
                "Name": "straks-data",
                "Options": {},
                "Scope": "local"
            }
        ]

        # The 'Mountpoint' directory is the system location of all your user files that reside within the container.
        # 'cd' into this directory - use sudo if you have permission issues - and then copy your conf 
        # and wallet files over existing files that may exist in the `.straks/` folder
        # WARNING: make sure to stop the `straks-node` process before changing config or wallet files

6. Simple json-rpc call to straks-node from another machine (or host):

        # username and password can be found in the `straks.conf` file
        # daemon-host-ip can be localhost/0.0.0.0/127.0.0.1 or a lan/wan ip address
        $ curl -s --user '<username>:<password>' --data-binary '{"jsonrpc": "2.0","method": "getinfo", "params": [] }' -H 'content-type: application/json-rpc;' http://<daemon-host-ip>:7574

   If you have `jq` installed, you can do some pretty json printing:
        
        $ curl -s --user '<username>:<password>' --data-binary '{"jsonrpc": "2.0","method": "getinfo", "params": [] }' -H 'content-type: application/json-rpc;' http://127.0.0.1:7574 | jq '.'

   Or `python -m json.tool`:

        $ curl -s --user '<username>:<password>' --data-binary '{"jsonrpc": "2.0","method": "getinfo", "params": [] }' -H 'content-type: application/json-rpc;' http://127.0.0.1:7574 | python -m json.tool


Documentation
-------------

* Additional documentation in the [docs folder](docs).
