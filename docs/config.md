straks-node Config Tuning
=========================

You can use environment variables to customize config ([see docker run environment options](https://docs.docker.com/engine/reference/run/#/env-environment-variables)):

        docker run -v straks-data:/straks --name=straks-node -d \
            -p 7575:7575 \
            -p 127.0.0.1:7574:7574 \
            -e PRINTTOCONSOLE=1 \
            -e RPCUSER=ustraks \
            -e RPCPASSWORD=mysecretrpcpassword \
            squbs/straks-node

Or you can use your very own config file like that:

        docker run -v straks-data:/straks --name=straks-node -d \
            -p 7575:7575 \
            -p 127.0.0.1:7574:7574 \
            -v /etc/mystraks.conf:/straks/.straks/straks.conf \
            squbs/straks-node
