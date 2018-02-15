bulwark-docker Config Tuning
=========================

You can use environment variables to customize config ([see docker run environment options](https://docs.docker.com/engine/reference/run/#/env-environment-variables)):

        docker run -v bulwark-data:/bulwark --name=bulwark-docker -d \
            -p 52544:52544 \
            -p 127.0.0.1:52543:52543 \
            -e PRINTTOCONSOLE=1 \
            -e RPCUSER=ubulwark \
            -e RPCPASSWORD=mysecretrpcpassword \
            8eph/bulwark-docker

Or you can use your very own config file like that:

        docker run -v bulwark-data:/bulwark --name=bulwark-docker -d \
            -p 52544:52544 \
            -p 127.0.0.1:52543:52543 \
            -v /etc/mybulwark.conf:/bulwark/.bulwark/bulwark.conf \
            8eph/bulwark-docker

docker run -v bulwark-data:/bulwark --name=bulwark-docker -d -p 52544:52544 -p 127.0.0.1:52543:52543 -e PRINTTOCONSOLE=1 -e RPCUSER=ubulwark -e RPCPASSWORD=mysecretrpcpassword            8eph/bulwark-docker