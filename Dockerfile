FROM ubuntu:xenial
MAINTAINER squbs <squbs@straks.io>

ARG USER_ID
ARG GROUP_ID

ENV HOME /straks
ENV STRAKS_VER 1.14.5.2

# add user with specified (or default) user/group ids
ENV USER_ID ${USER_ID:-1000}
ENV GROUP_ID ${GROUP_ID:-1000}

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -g ${GROUP_ID} straks \
	&& useradd -u ${USER_ID} -g straks -s /bin/bash -m -d /straks straks

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-get update
RUN apt-get install -y build-essential
RUN apt-get install -y libtool autotools-dev autoconf automake
RUN apt-get install -y libssl-dev
RUN apt-get install -y libboost-all-dev
RUN apt-get install -y pkg-config 
RUN apt-get -y install python-software-properties software-properties-common git
RUN add-apt-repository -y ppa:bitcoin/bitcoin
RUN apt-get -y update
RUN apt-get install -y libdb4.8-dev
RUN apt-get install -y libdb4.8++-dev
RUN apt-get install -y libminiupnpc-dev
RUN apt-get install -y libqt4-dev libprotobuf-dev protobuf-compiler
RUN apt-get install -y libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev
RUN apt-get install -y libcanberra-gtk-module
RUN apt-get install -y gtk2-engines-murrine
RUN apt-get install -y libqrencode-dev
RUN apt-get install -y libevent-dev
RUN apt-get install -y libzmq3-dev
RUN apt-get install -y wget

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# [1] if you want to compile from source, needs a lot of ram
#RUN cd ${HOME} && git clone https://github.com/straks/straks.git
#RUN cd ${HOME}/straks && ./autogen.sh
#RUN cd ${HOME}/straks && ./configure
#RUN cd ${HOME}/straks && make
#RUN cd ${HOME}/straks && cp straksd /usr/bin/straksd && cp straks-cli /usr/bin/straks-cli && cp straks-tx /usr/bin/straks-tx && cp qt/straks-qt /usr/bin/straks-qt

# [2] pre-compiled binaries
RUN cd ${HOME} && wget https://github.com/straks/straks/releases/download/${STRAKS_VER}/straks-${STRAKS_VER}-linux-amd64.tar.gz && tar zxvf straks-${STRAKS_VER}-linux-amd64.tar.gz

RUN cd ${HOME}/straks-${STRAKS_VER}-linux-amd64 && cp straksd /usr/bin/straksd && cp straks-cli /usr/bin/straks-cli && cp straks-tx /usr/bin/straks-tx && cp straks-qt /usr/bin/straks-qt

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

VOLUME ["/straks"]

EXPOSE 7575 7574

WORKDIR /straks

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["straks_oneshot"]
