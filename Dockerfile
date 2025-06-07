# Ubuntu based container for building perfbook (for rootless mode).
# build ARG:
#    rel: Ubuntu release, default is "latest", means latest LTS.
#
# build example:
#    docker build -t <image tag> [--build-arg rel=<release tag>] .
#
# run example:
#    docker run --rm -it -v <perfbook Git dir (abs)>:/work <image tag>
#
ARG distro=ubuntu
ARG rel=latest
FROM $distro:$rel
ARG rel
ENV REL $rel
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get autoremove -y \
 && DEBIAN_FRONTEND=noninteractive TZ=UTC apt-get install -y \
      tzdata \
 && apt-get install -y --no-install-recommends \
      fig2ps \
      inkscape \
      librsvg2-bin \
      graphviz \
      psutils \
      texlive-publishers \
      texlive-pstricks \
      texlive-science \
      texlive-fonts-extra \
      texlive-font-utils \
      fonts-freefont-ttf \
      lmodern \
      fonts-liberation2 \
      fonts-urw-base35 \
      fonts-dejavu-core \
      fonts-linuxlibertine \
      tex-gyre \
      fonts-texgyre \
      make \
      git \
      curl \
      ca-certificates \
      gnupg \
      coreutils \
      gnuplot-nox \
      unzip \
      time \
      latexmk \
      texlive-xetex \
      texlive-luatex \
      file \
      poppler-utils \
      perl-doc \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
COPY steel-city-comic.regular.ttf /usr/local/share/fonts/
RUN cd /etc/fonts/conf.d/ \
 && echo '<?xml version="1.0"?>\n\
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">\n\
<fontconfig>\n\
  <dir>/usr/share/texlive/texmf-dist/fonts/opentype</dir>\n\
</fontconfig>' > 09-texlive-fonts.conf \
 && fc-cache -sf
WORKDIR /opt
RUN curl https://gitlab.com/latexpand/latexpand/-/archive/v1.3/latexpand-v1.3.tar.gz -L -O \
 &&   sha512sum latexpand-v1.3.tar.gz > CHECKSUM \
 &&   echo "2e8030b478a6ea03979cec0e03ca0845f67bc7df607b2eaa58660a35e4216747be21e2a01b8700dffd244a2d5265f08eef60b65c0dbc7fcf5123ba773fb1903d  latexpand-v1.3.tar.gz" > CHECKSUM_EXPECTED \
 &&   cmp CHECKSUM CHECKSUM_EXPECTED \
 &&   tar --no-same-owner --no-same-permissions -xzf latexpand-v1.3.tar.gz \
 &&   sed -i -e 's/@LATEXPAND_VERSION@/v1.3/' latexpand-*/latexpand \
 &&   cp latexpand-*/latexpand /usr/local/bin \
 &&   rm latexpand-v1.3.tar.gz CHECKSUM*
RUN if [ $REL = "focal" ] ; then \
      curl https://mirrors.ctan.org/macros/latex/contrib/parskip.zip -L -O \
 &&   unzip parskip.zip \
 &&   cd parskip && latex parskip.ins && cd .. \
 &&   mkdir -p /usr/local/share/texmf/tex/latex/parskip \
 &&   cp parskip/parskip.sty /usr/local/share/texmf/tex/latex/parskip \
 &&   texhash /usr/local/share/texmf \
 &&   rm -rf parskip* \
 ;  fi
WORKDIR /work
CMD /bin/bash
