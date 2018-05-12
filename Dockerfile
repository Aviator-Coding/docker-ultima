ARG BDB_VERSION="4.8.30.NC"

FROM lepetitbloc/bdb:$BDB_VERSION



## Wallet Ports ###
EXPOSE 21520 21521

RUN apt-get update -y && apt-get  --no-install-recommends install -y  \
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
	ca-certificates\
&& rm -rf /var/lib/apt/lists/* \
&& useradd -lrUm ultima

WORKDIR /tmp/ultima
# build
RUN git clone https://github.com/ultimammp/ultima.git /tmp/ultima 
    #chmod +x autogen.sh share/genbuild.sh src/leveldb/build_detect_platform \
&& ./autogen.sh \
&& ./configure \
&& make \
&& strip src/ultimad src/ultima-cli src/ultima-tx \
&& mv src/ultimad /usr/local/bin/ \
&& mv src/ultima-cli /usr/local/bin/ \
&& mv src/ultima-tx /usr/local/bin/ \
# clean
&& rm -rf /tmp/ultima

USER ultima

WORKDIR /home/ultima

RUN mkdir -p .ultimacore data

COPY wallet/.ultimacore/ .ultimacore/

ENTRYPOINT ["/usr/local/bin/ultimad", "-reindex", "-printtoconsole", "-logtimestamps=1", "-datadir=data", "-conf=../.ultimacore/ultima.conf", "-mnconf=../.ultimacore/masternode.conf", "-port=21520", "-rpcport=21521"]
CMD ["-rpcallowip=127.0.0.1", "-server=1", "-masternode=0"]