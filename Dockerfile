# image build command:
#   docker build --rm --force-rm --no-cache -f Dockerfile -t yourUsername/admidio:v4.0.3 .

FROM ubuntu:20.04
MAINTAINER Stefan Schatz

# set arguments
ARG GITURL="https://github.com/Admidio/admidio.git"
ARG TZ="Europe/Vienna"
ARG ADM_BRANCH="master"

# set enviroments
ENV GITURL="${GITURL}"
ENV TZ="${TZ}"
ENV ADM_BRANCH="${ADM_BRANCH}"
ENV DEBIAN_FRONTEND="noninteractive"
ENV APACHECONF="/etc/apache2/sites-available"
ENV WWW="/var/www"
ENV ADM="admidio"
ENV PROV="provision"


RUN apt-get update && apt-get dist-upgrade -y && \
    apt-get install -y apache2 php7.4 php7.4-cli php7.4-gd \
    php7.4-mysql php7.4-pgsql php7.4-imap php7.4-xml php7.4-mbstring php7.4-json \
    zip unzip gzip git sendmail && \
    rm -rf /var/lib/apt/lists/*

COPY admidio_apache.conf ${APACHECONF}/admidio.conf
COPY entrypoint.sh /entrypoint.sh

WORKDIR ${WWW}
RUN a2dissite 000-default.conf && a2ensite admidio.conf

RUN echo "Clone Admidio from git (${GITURL}) with branch ${ADM_BRANCH}" && \
    git clone --depth 1 --single-branch --branch ${ADM_BRANCH} ${GITURL} ${ADM} && \
    chown -R www-data:www-data ${ADM} && \
    chmod -R 777 ${ADM}/adm_my_files

RUN mkdir -p ${PROV} && \
    cp -a ${ADM}/adm_my_files ${ADM}/adm_plugins ${ADM}/adm_themes ${PROV}/

RUN sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 16G/g" /etc/php/7.4/apache2/php.ini
RUN sed -i "s/post_max_size = 8M/post_max_size = 16G/g" /etc/php/7.4/apache2/php.ini
RUN sed -i "s#^ErrorLog.*#ErrorLog /proc/self/fd/2#g" /etc/apache2/apache2.conf

VOLUME ["${WWW}/${ADM}/adm_my_files", "${WWW}/${ADM}/adm_themes", "${WWW}/${ADM}/adm_plugins" ,"${APACHECONF}"]

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
