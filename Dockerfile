ARG BDB_VERSION="4.8.30.NC"

FROM lepetitbloc/bdb:$BDB_VERSION

ARG USE_UPNP=1
ENV USE_UPNP=$USE_UPNP

EXPOSE 21521 21520

RUN apt-get update -y && apt-get install -y  \
    libssl-dev \
    libboost-system-dev \
    libboost-filesystem-dev \
    libboost-chrono-dev \
    libboost-program-options-dev \
    libboost-test-dev \
    libboost-thread-dev \
    libminiupnpc-dev \
    libqrencode-dev \
    libgmp-dev \
    libevent-dev \
    libzmq3-dev \
    automake \
    pkg-config \
    git \
    bsdmainutils \
&& rm -rf /var/lib/apt/lists/* \
&& useradd -lrUm ultima \
&& git clone https://github.com/ultimammp/ultima.git /tmp/ultima
WORKDIR /tmp/ultima

# build
RUN chmod +x autogen.sh share/genbuild.sh src/leveldb/build_detect_platform \
&& ./autogen.sh \
&& ./configure CPPFLAGS="-I/usr/local/db4/include -O2" LDFLAGS="-L/usr/local/db4/lib" \
&& make \
&& strip src/ultimad src/ultima-cli src/ultima-tx \
&& mv src/ultimad /usr/local/bin/ \
&& mv src/ultima-cli /usr/local/bin/ \
&& mv src/ultima-tx /usr/local/bin/ \
# clean
&& rm -rf /tmp/ultima

USER ultima

WORKDIR /home/ultima

RUN mkdir -p .ultima data

COPY wallet/.ultima/ .ultima/

ENTRYPOINT ["/usr/local/bin/ultimad", "-reindex", "-printtoconsole", "-logtimestamps=1", "-datadir=data", "-conf=../.ultima/ultima.conf", "-mnconf=../.ultima/masternode.conf", "-port=9918", "-rpcport=9919"]
CMD ["-rpcallowip=127.0.0.1", "-server=1", "-masternode=0"]
