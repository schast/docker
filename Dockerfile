FROM debian:stretch
MAINTAINER Guenter Bailey

RUN apt-get update && apt-get dist-upgrade -y && \
    apt-get install -y apache2 libapache2-mod-php7.0 php7.0 \
    php7.0-common php7.0-mcrypt php7.0-mysql php7.0-cli \
    php7.0-gd php7.0-pgsql php7.0-xml php7.0-zip zip unzip gzip git && \
    rm -rf /var/lib/apt/lists/*


# set enviroments
ENV GITURL="https://github.com/Admidio/admidio.git"
ENV APACHECONF="/etc/apache2/sites-available"
ENV WWW="/var/www"
ENV ADM="admidio"
ENV PROV="provision"
ENV ADM_BRANCH="v3.3.6"

COPY admidio_apache.conf $APACHECONF/"admidio.conf"
COPY entrypoint.sh /"entrypoint.sh"

WORKDIR $WWW
RUN a2dissite 000-default.conf && a2ensite admidio.conf

#Admidio from Github
RUN echo "Clone Admidio from GiT with Branch $ADM_BRANCH" && \
    git clone --depth 1 --single-branch --branch $ADM_BRANCH https://github.com/Admidio/admidio.git $ADM && \
    chown -R www-data:www-data $ADM && chmod -R 777 $ADM/adm_my_files

RUN mkdir -p $PROV && \
    cp -a $ADM/adm_my_files $ADM/adm_plugins $ADM/adm_themes $PROV/

RUN sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 30M/g" /etc/php/7.0/apache2/php.ini
RUN sed -i "s/post_max_size = 8M/post_max_size = 40M/g" /etc/php/7.0/apache2/php.ini

VOLUME ["$WWW/$ADM/adm_my_files", "$WWW/$ADM/adm_themes", "$WWW/$ADM/adm_plugins" ,"$APACHECONF"]
EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]
