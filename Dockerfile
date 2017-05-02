FROM alpine:3.5
MAINTAINER Guenter Bailey

# since docker v1.9, we can use --build-arg variable
# https://docs.docker.com/engine/reference/builder/#arg
ARG branch
ENV ADM_BRANCH=${branch:-master}

# install required packages
RUN apk update
RUN apk add apache2 php7-apache2 php7 php7-common php7-mcrypt php7-mysqli php7-pgsql php7-gd php7-xml php7-zip git zip unzip gzip

# set enviroments
ENV GITURL="https://github.com/Admidio/admidio.git"
ENV APACHECONF="/etc/apache2"
ENV WWW="/var/www"
ENV ADM="admidio"
ENV PROV="provision"

COPY admidio_apache.conf $APACHECONF/"admidio_apache.conf"
RUN echo "Include $APACHECONF/admidio_apache.conf" >> $APACHECONF/httpd.conf
COPY entrypoint.sh /"entrypoint.sh"

WORKDIR $WWW

#Admidio Git
RUN echo "Clone Admidio from GiT with Branch $ADM_BRANCH" && \
git clone --depth 1 --single-branch --branch $ADM_BRANCH https://github.com/Admidio/admidio.git $ADM && \
chown -R apache:apache $ADM && \
chmod -R 777 $ADM/adm_my_files

#create prov folder
RUN mkdir -p $PROV && \
cp -a $ADM/adm_my_files $ADM/adm_plugins $ADM/adm_themes $PROV/

RUN sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 30M/g" /etc/php7/php.ini
RUN sed -i "s/post_max_size = 8M/post_max_size = 40M/g" /etc/php7/php.ini

VOLUME ["$WWW/$ADM/adm_my_files", "$WWW/$ADM/adm_themes", "$WWW/$ADM/adm_plugins" ,"$APACHECONF"]

# Port to expose
EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
