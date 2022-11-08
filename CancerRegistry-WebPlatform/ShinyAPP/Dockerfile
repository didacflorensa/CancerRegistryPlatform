FROM rocker/verse:4.1.2


## JDK and rJava
RUN apt-get update && apt-get install -y \
    sudo \
    gdebi-core \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    xtail \
    wget

## JDK and rJava

RUN apt-get install -y --no-install-recommends \

   ed \
   default-jdk \
   libgdal-dev \
   libgeos-c1v5 \
   default-jre \
   libproj-dev \
   icedtea-netx \
   libbz2-dev \
   libcairo2-dev \
   libgdal-dev \
   libicu-dev \
   liblzma-dev \
   libproj-dev \
   libgeos-dev \
   libgsl0-dev \
   librdf0-dev \
   librsvg2-dev \
   libv8-dev \
   libxcb1-dev \
   libxdmcp-dev \
   libxslt1-dev \
   libxt-dev \
   mdbtools \
   netcdf-bin \

 && . /etc/environment 

RUN apt-get install -y texlive-latex-base  --no-install-recommends
RUN apt-get install -y lmodern  --no-install-recommends
RUN apt-get install -y locales locales-all
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

RUN apt-get install -y libjq-dev
RUN apt-get install -y libudunits2-dev
## tidyverse, devtools and related R packages already inherited from rocker/verse
# Download and install shiny server
RUN wget --no-verbose https://download3.rstudio.org/ubuntu-14.04/x86_64/VERSION -O "version.txt" && \
    VERSION=$(cat version.txt)  && \
    wget --no-verbose "https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
    gdebi -n ss-latest.deb && \
    rm -f version.txt ss-latest.deb && \
    . /etc/environment && \
    R -e "install.packages(c('shiny', 'rmarkdown', 'shinydashboard', 'leaflet', 'RColorBrewer','jsonlite', 'DT', 'geojsonio','ggplot2', 'reshape2', 'plyr', 'tidyverse', 'ggpol', 'RColorBrewer', 'httr', 'htmltools', 'rjson', 'rgdal', 'plotly', 'shinyjs', 'rjson', 'xlsx', 'raster', 'devtools'))" && \
    R -e "devtools::install_version('shinydashboardPlus', version='0.7.5',repos = 'http://cran.us.r-project.org')" && \
    cp -R /usr/local/lib/R/site-library/shiny/examples/* /srv/shiny-server/ && \
    chown shiny:shiny /var/lib/shiny-server /usr/local/lib/R/*

EXPOSE 3838

COPY shiny-server.sh /usr/bin/shiny-server.sh

RUN ["chmod", "+x", "/usr/bin/shiny-server.sh"]
CMD ["/usr/bin/shiny-server.sh"]



#Export projects Volume

