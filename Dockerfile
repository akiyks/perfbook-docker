FROM ubuntu:focal

RUN apt-get update && apt-get install -y locales && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 && \
    rm -rf /var/lib/apt/lists/*
ENV LANG en_US.utf8
RUN apt-get update && DEBIAN_FRONTEND=noninteractive TZ=UTC apt-get install -y tzdata && \
    rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y fig2ps inkscape xfig graphviz psutils \
    texlive-publishers texlive-pstricks texlive-science texlive-fonts-extra \
    make nano vim git curl ca-certificates unzip gnuplot-nox time && \
    rm -rf /var/lib/apt/lists/*
WORKDIR /opt
COPY fontcheck.txt /opt/fontcheck.txt
RUN curl https://gitlab.com/latexpand/latexpand/-/archive/v1.3/latexpand-v1.3.tar.gz -o - | tar xfz - && \
    sed -i -e 's/@LATEXPAND_VERSION@/v1.3/' latexpand-v1.3/latexpand && \
    cp latexpand-v1.3/latexpand /usr/local/bin && \
    mkdir steel-city-comic && cd steel-city-comic && \
    curl https://www.1001fonts.com/download/steel-city-comic.zip -L -o steel-city-comic.zip && \
    unzip steel-city-comic.zip && rm steel-city-comic.zip && \
    sha256sum -c ../fontcheck.txt | grep -q OK && \
    cd /usr/local/share/fonts && \
    ln -s /opt/steel-city-comic/scb.ttf steel-city-comic.regular.ttf && \
    cd /opt && fc-cache /usr/local/share/fonts
ARG uid=1000
ARG gid=1000
ARG user=perfbook
ARG group=perfbook
RUN if [ $uid -ne 0 ] ; then \
    groupadd -g $gid $group ; \
    useradd -u $uid -g $gid -m $user ; \
    fi
VOLUME /work
USER $uid:$gid
WORKDIR /work
CMD /bin/bash
