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
# Note: rel=bionic doesn't support build by xelatex and lualatex 
#
ARG rel=latest
FROM ubuntu:$rel
ARG rel
ENV REL $rel
RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get autoremove -y \
 && apt-get install -y locales \
 && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
ENV LANG en_US.utf8
RUN apt-get update \
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
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
COPY steel-city-comic.regular.ttf /usr/local/share/fonts/
RUN mkdir -p /etc/fonts/conf.avail && cd /etc/fonts/conf.avail \
 && echo '<?xml version="1.0"?>\n\
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">\n\
<fontconfig>\n\
  <dir>/usr/share/texlive/texmf-dist/fonts/opentype</dir>\n\
</fontconfig>' > 09-texlive-fonts.conf \
 && ln -sf /etc/fonts/conf.avail/09-texlive-fonts.conf /etc/fonts/conf.d/ \
 && fc-cache -sf
WORKDIR /opt
RUN if [ $REL = "bionic" ] ; then \
      curl https://mirrors.ctan.org/macros/latex/contrib/cleveref.zip -L -O \
 &&   unzip cleveref.zip \
 &&   curl https://mirrors.ctan.org/macros/latex/contrib/epigraph.zip -L -O \
 &&   unzip epigraph.zip \
 &&   curl https://mirrors.ctan.org/macros/latex/contrib/glossaries-extra.zip -L -O \
 &&   unzip glossaries-extra.zip \
 &&   cd cleveref && latex cleveref.ins && cd .. \
 &&   mkdir -p /usr/local/share/texmf/tex/latex/cleveref \
 &&   cp cleveref/cleveref.sty /usr/local/share/texmf/tex/latex/cleveref \
 &&   cd epigraph && latex epigraph.ins && cd .. \
 &&   mkdir -p /usr/local/share/texmf/tex/latex/epigraph \
 &&   cp epigraph/epigraph.sty /usr/local/share/texmf/tex/latex/epigraph \
 &&   cd glossaries-extra && latex glossaries-extra.ins && cd .. \
 &&   mkdir -p /usr/local/share/texmf/tex/latex/glossaries-extra \
 &&   cp glossaries-extra/*.sty /usr/local/share/texmf/tex/latex/glossaries-extra \
 &&   rm *.zip \
 &&   rm -rf cleveref/ epigraph/ glossaries-extra/ \
 &&   cd /usr/local/share/texmf/tex/latex/glossaries-extra \
 &&     mv glossaries-extra.sty glossaries-extra-latest.sty \
 &&     mv glossaries-extra-bib2gls.sty glossaries-extra-bib2gls-latest.sty \
 &&     mv glossaries-extra-stylemods.sty glossaries-extra-stylemods-latest.sty \
 &&     mv glossary-bookindex.sty glossary-bookindex-latest.sty \
 &&     mv glossary-longextra.sty glossary-longextra-latest.sty \
 &&     mv glossary-topic.sty glossary-topic-latest.sty \
 &&     ln -s glossaries-extra-2021-11-22.sty glossaries-extra.sty \
 &&     ln -s glossaries-extra-bib2gls-2021-11-22.sty glossaries-extra-bib2gls.sty \
 &&     ln -s glossaries-extra-stylemods-2021-11-22.sty glossaries-extra-stylemods.sty \
 &&     ln -s glossary-bookindex-2021-11-22.sty glossary-bookindex.sty \
 &&     ln -s glossary-longextra-2021-11-22.sty glossary-longextra.sty \
 &&     ln -s glossary-topic-2021-11-22.sty glossary-topic.sty \
 &&   cd /opt \
 &&   texhash /usr/local/share/texmf \
 &&   curl https://mirrors.ctan.org/graphics/a2ping.zip -L -O \
 &&   unzip a2ping.zip \
 &&   cp a2ping/a2ping.pl /usr/local/bin/a2ping \
 ;  else \
      curl https://gitlab.com/latexpand/latexpand/-/archive/v1.3/latexpand-v1.3.tar.gz -L -O \
 &&   sha512sum latexpand-v1.3.tar.gz > CHECKSUM \
 &&   echo "2e8030b478a6ea03979cec0e03ca0845f67bc7df607b2eaa58660a35e4216747be21e2a01b8700dffd244a2d5265f08eef60b65c0dbc7fcf5123ba773fb1903d  latexpand-v1.3.tar.gz" > CHECKSUM_EXPECTED \
 &&   cmp CHECKSUM CHECKSUM_EXPECTED \
 &&   tar xfz latexpand-v1.3.tar.gz \
 &&   sed -i -e 's/@LATEXPAND_VERSION@/v1.3/' latexpand-*/latexpand \
 &&   cp latexpand-*/latexpand /usr/local/bin \
 &&   rm latexpand-v1.3.tar.gz CHECKSUM* \
 ;  fi
WORKDIR /work
CMD /bin/bash
