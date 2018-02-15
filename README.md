BULWARK Node For Docker
======================

[![Docker Stars](https://img.shields.io/docker/stars/8eph/bulwark-docker.svg)](https://hub.docker.com/r/8eph/bulwark-docker/)
[![Docker Pulls](https://img.shields.io/docker/pulls/8eph/bulwark-docker.svg)](https://hub.docker.com/r/8eph/bulwark-docker/)

Docker image that runs a BULWARK node in a container for easy deployment.


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

    curl https://raw.githubusercontent.com/bulwark/bulwark-docker/master/bootstrap-host.sh | sh

You will most likely need to run the above twice if your user is not part of the Docker group or it is a new installation of Docker. After running the above the first time, and it fails citing permission issues, log out and then log back in and then ensure that user is a member of the Docker group (run `id`).  User will also need `sudo` permissions.

Note: use `-H 'Cache-Control: no-cache'` with the curl command to return non-cached data from the web server.

Finally, in order to start the node manually, run:

    sudo systemctl start docker-bulwark-docker
    

Quick Start
-----------

1. Create a `bulwark-data` volume to persist the BULWARK blockchain data, should exit immediately.  The `bulwark-data` container will store the blockchain when the node container is recreated (software upgrade, reboot, etc):

        docker volume create --name=bulwark-data
        docker run -v bulwark-data:/bulwark --name=bulwark-docker -d p 52544:52544 -p 52543:52543 8eph/bulwark-docker

2. Verify that the container is running and `bulwark-docker` daemon is downloading the blockchain:

        $ docker ps
        CONTAINER ID        IMAGE                         COMMAND             CREATED             STATUS              PORTS                                              NAMES
        ee825ac17747     8eph/bulwark-docker:latest     "bulwark_oneshot"       2 seconds ago       Up 1 seconds        127.0.0.1:52544->52544/tcp, 0.0.0.0:52543->52543/tcp   bulwark-docker

3. You can then access the daemon's output thanks to the [docker logs command]( https://docs.docker.com/reference/commandline/cli/#logs)

        $ docker logs -f bulwark-docker

4. Install optional init scripts for upstart and systemd located in the `init` directory. Alternatively you can run step 1 with the following additional arguments `-dit --restart unless-stopped ` to have the container restart on failure on system restart.

5. If not using upstart and systemd, you can use watchtower to keep your docker node up to date. 

```
docker run -dit --restart unless-stopped   -d  --name watchtower   -v /var/run/docker.sock:/var/run/docker.sock   v2tec/watchtower bulwark-docker
```




General Commands
----------------

1. Open a bash shell within the running container and issue commands to the daemon:

        $ docker exec -it bulwark-docker bash
        $ bulwark-cli getinfo

2. Copy file (e.g. bulwark.conf) in and out of the container: 
        
        # Copy to your local dir:
        $ docker cp bulwark-docker:/bulwark/.bulwark/bulwark.conf .
        
        # Copy back to the container: 
        $ docker bulwark.conf bulwark-docker:/bulwark/.bulwark/bulwark.conf 

        # Stop/start the container
        $ docker stop bulwark-docker
        $ docker start bulwark-docker

3. Backup wallet (two approaches): 

        # Approach 1 
        # This will create a human readable file dump (depending on encryption status etc):

        (a) Dump wallet:
            $ docker exec -it  bulwark-docker bulwark-cli dumpwallet backup_wallet.dat
        
        (b) Copy to local dir: 
            $ docker cp bulwark-docker:/bulwark/backup_wallet.dat .


        # Approach 2
        # This will create a binary file:

        (a) Copy dat file to local dir: 
            $ docker cp bulwark-docker:/bulwark/.bulwark/wallet.dat backup_wallet.dat

4. Check `bulwark-docker` log file using system `tail -f` command:

        $ docker ps

        # Note the 'COINTAINER ID' for bulwark-docker
        CONTAINER ID        IMAGE                 COMMAND                  CREATED             STATUS              PORTS                                                       NAMES
        ee825ac17747        8eph/bulwark-docker:1.14.5   "docker-entrypoint..."   21 seconds ago      Up 21 seconds       52544/tcp, 0.0.0.0:52543->52543/tcp   bulwark-docker`

        # Run inspect command on container id
        $ docker inspect --format='{{.LogPath}}' ee825ac17747

        # Docker will output location and filename of the container log file:  
        $ /var/lib/docker/containers/ee825ac17747f2abaf627600860697e1213249ab83bb0cf136684dd4a4b7f55d/ee825ac17747f2abaf627600860697e1213249ab83bb0cf136684dd4a4b7f55d-json.log
        
        $ tail -f ee825ac17747f2abaf627600860697e1213249ab83bb0cf136684dd4a4b7f55d-json.log

5. Modify `bulwark.conf` and/or `wallet.dat` files without `docker cp`:

        $ docker volume inspect bulwark-data
       
        # output: 
        [
            {
                "CreatedAt": "2017-11-26T16:07:53Z",
                "Driver": "local",
                "Labels": {},
                "Mountpoint": "/var/lib/docker/volumes/bulwark-data/_data",
                "Name": "bulwark-data",
                "Options": {},
                "Scope": "local"
            }
        ]

        # The 'Mountpoint' directory is the system location of all your user files that reside within the container.
        # 'cd' into this directory - use sudo if you have permission issues - and then copy your conf 
        # and wallet files over existing files that may exist in the `.bulwark/` folder
        # WARNING: make sure to stop the `bulwark-docker` process before changing config or wallet files

6. Simple json-rpc call to bulwark-docker from another machine (or host):

        # username and password can be found in the `bulwark.conf` file
        # daemon-host-ip can be localhost/0.0.0.0/127.0.0.1 or a lan/wan ip address
        $ curl -s --user '<username>:<password>' --data-binary '{"jsonrpc": "2.0","method": "getinfo", "params": [] }' -H 'content-type: application/json-rpc;' http://<daemon-host-ip>:52543

   If you have `jq` installed, you can do some pretty json printing:
        
        $ curl -s --user '<username>:<password>' --data-binary '{"jsonrpc": "2.0","method": "getinfo", "params": [] }' -H 'content-type: application/json-rpc;' http://127.0.0.1:52543 | jq '.'

   Or `python -m json.tool`:

        $ curl -s --user '<username>:<password>' --data-binary '{"jsonrpc": "2.0","method": "getinfo", "params": [] }' -H 'content-type: application/json-rpc;' http://127.0.0.1:52543 | python -m json.tool


Documentation
-------------

* Additional documentation in the [docs folder](docs).
