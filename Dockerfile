FROM debian:jessie
MAINTAINER Guenter Bailey

RUN apt-get update && apt-get dist-upgrade -y && \
    apt-get install -y apache2 libapache2-mod-php5 php5 php5-common \
    php5-mcrypt php5-mysql php5-cli php5-gd zip unzip gzip php5-pgsql \
    git && rm -rf /var/lib/apt/lists/*

# set enviroments
ENV GITURL="https://github.com/Admidio/admidio.git"
ENV APACHECONF="/etc/apache2/sites-available"
ENV WWW="/var/www"
ENV ADM="admidio"
ENV PROV="provision"
ENV ADM_BRANCH="v3.3"

COPY admidio_apache.conf $APACHECONF/"admidio.conf"
COPY entrypoint.sh /"entrypoint.sh"

WORKDIR $WWW
RUN a2dissite 000-default.conf && a2ensite admidio.conf

RUN echo "Clone Admidio from GiT with Branch $ADM_BRANCH" && \
    git clone --depth 1 --single-branch --branch $ADM_BRANCH https://github.com/Admidio/admidio.git $ADM && \
    chown -R www-data:www-data $ADM && chmod -R 777 $ADM/adm_my_files

RUN mkdir -p $PROV && \
    cp -a $ADM/adm_my_files $ADM/adm_plugins $ADM/adm_themes $PROV/

RUN sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 30M/g" /etc/php5/apache2/php.ini
RUN sed -i "s/post_max_size = 8M/post_max_size = 40M/g" /etc/php5/apache2/php.ini

VOLUME ["$WWW/$ADM/adm_my_files", "$WWW/$ADM/adm_themes", "$WWW/$ADM/adm_plugins" ,"$APACHECONF"]
EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]
