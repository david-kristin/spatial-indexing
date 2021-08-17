FROM postgres:13.3

ENV POSTGIS_MAJOR 3
ENV POSTGIS_VERSION 3.1.2+dfsg-1~exp2.pgdg100+1

RUN apt-get update \
     && apt-cache showpkg postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR \
     && apt-get install -y --no-install-recommends \
         postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR=$POSTGIS_VERSION \
         postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR-scripts=$POSTGIS_VERSION \
     && apt-get clean \
     && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

RUN mkdir -p /docker-entrypoint-initdb.d

COPY ./initdb.sh /docker-entrypoint-initdb.d/postgis.sh
COPY ./update.sh /usr/local/bin
