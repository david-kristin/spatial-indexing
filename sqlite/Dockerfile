FROM debian:bullseye-slim

RUN apt-get -y update \
     && apt-get install -y \
         binutils \
         build-essential \
         gdal-bin \
         libfreexl-dev \
         libgeos-dev \
         libminizip-dev \
         libproj-dev \
         librttopo-dev \
         libsqlite3-dev \
         libxml2-dev \
         libz-dev \
         pkg-config \
         sqlite3 \
         wget \
     && apt-get clean \
     && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

RUN mkdir /databases

WORKDIR /databases

RUN wget https://www.gaia-gis.it/gaia-sins/libspatialite-sources/libspatialite-5.0.1.tar.gz \
     && tar xaf libspatialite-5.0.1.tar.gz \
     && cd libspatialite-5.0.1 \
     && ./configure \
     && make \
     && make install \
     && make clean

ENTRYPOINT ["sqlite3"]
