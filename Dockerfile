FROM ubuntu:artful
MAINTAINER 8eph <8eph@protonmail.com>

ARG USER_ID
ARG GROUP_ID

ENV HOME /bulwark
ENV BULWARK_VER 1.2.1.0
ENV UBUNTU_VER 17.10

# add user with specified (or default) user/group ids
ENV USER_ID ${USER_ID:-1000}
ENV GROUP_ID ${GROUP_ID:-1000}

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -g ${GROUP_ID} bulwark \
	&& useradd -u ${USER_ID} -g bulwark -s /bin/bash -m -d /bulwark bulwark

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get -y autoremove
RUN apt-get install -y wget nano htop apt-utils
RUN apt-get install -y build-essential libtool autotools-dev autoconf automake libssl-dev libboost-all-dev software-properties-common curl
RUN add-apt-repository ppa:bitcoin/bitcoin
RUN apt-get update
RUN apt-get -y install libzmq3-dev libdb4.8-dev libdb4.8++-dev libminiupnpc-dev libqt4-dev libprotobuf-dev protobuf-compiler libqrencode-dev pkg-config

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# [2] pre-compiled binaries
RUN cd ${HOME} && wget https://github.com/bulwark-crypto/Bulwark/releases/download/${BULWARK_VER}/bulwark-${BULWARK_VER}-x86_64-ubuntu${UBUNTU_VER}-gnu.gz -O bulwark.tar.gz && tar zxvf bulwark.tar.gz --strip-components 2
RUN cd ${HOME} && cp bulwark* /usr/bin/ && rm bulwark.tar.gz

# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.7
RUN set -x \
	&& apt-get update && apt-get install -y --no-install-recommends \
		ca-certificates \
		wget \
	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
	&& gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
	&& rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu \
	&& gosu nobody true \
	&& apt-get purge -y \
		ca-certificates \
		wget \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD ./bin /usr/local/bin

VOLUME ["/bulwark"]

EXPOSE 52544 52543

WORKDIR /bulwark

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["bulwark_oneshot"]
