# Admidio Vereinsverwaltung im Docker

## Was ist Admidio

*Admidio ist eine kostenlose Online-Mitgliederverwaltung, die für Vereine, Gruppen und Organisationen optimiert ist. 
Sie besteht neben der klassischen Mitgliederverwaltung aus einer Vielzahl an Modulen, die in eine neue oder bestehende 
Homepage eingebaut und angepasst werden können.*

*Registrierte Benutzer eurer Homepage haben durch Admidio u.a. Zugriff auf vordefinierte und frei konfigurierbare Mitgliederlisten, 
Personenprofile und eine Terminübersicht. Außerdem können Mitglieder in Gruppen zusammengelegt, Eigenschaften zugeordnet 
und nach diesen gesucht werden. [(c) Admidio.org 2017](https://www.admidio.org/dokuwiki/doku.php?id=de:2.0:index)*


## Inhalt

[*Warum Docker*](#warum-docker)

---
[*Container über Dockerhub Downloaden*](#container-%C3%BCber-dockerhub-downloaden)

[*Container erstellen*](#container-erstellen)

[*Container mit Docker Befehl erstellen*](#container-mit-docker-befehl-erstellen)

[*Container starten*](#container-starten)

---
[*Erklärung zu dem Start Befehl*](#erkl%C3%A4rung-zu-dem-start-befehl)

[*Container updaten*](#container-updaten)

[*Container über Git updaten*](#container-%C3%BCber-git-updaten)

---
[*Admidio Wiki*](#wiki-zu-admidio)

---
[*MySQL Benutzer und Datenbank in der Mysql-Shell erstellen*](#mysql-benutzer-und-datenbank-in-der-mysql-shell-erstellen)

---
[*Docker Compose*](#docker-compose)

[*Admidio mit Docker Compose und SSL Reverse Proxy*](#admidio-mit-docker-compose-und-ssl-reverse-proxy)


## Warum Docker

Da ich selber mehrere Server mit Docker verbunden habe, wollte ich jetzt für unseren Verein nicht wieder einen extra Webserver 
einrichten.

Natürlich würde vielleicht ein Webhoster auch gehen, da wir aber Bilder oben haben und es nicht weniger wird, ist ein günstiger 
Webhoster mit ca. 50GB Webspace eher schwer zu finden.

Und es gibt auch immer mehr Cloud Anbieter die mit Container Technik arbeiten z.b.: [Google Container Engine GCE](https://cloud.google.com/container-engine/), 
[Amazon EC2 Container Service](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/docker-basics.html),... 

Darum habe ich mir gedacht, warum nicht das in einem [Docker Container](https://hub.docker.com) einbauen.

## Container über Dockerhub Downloaden

Den Fertigen Container kann man einfach per [docker pull admidio/admidio:latest](https://hub.docker.com/r/admidio/admidio/) downloaden.

## Container erstellen

Um den Container selber Lokal zu erstellen, muss man das Git Repositority Klonen und zu dem jeweiligen Branch wechseln oder man ladet den jeweiligen Branch runter.

Danach in den Ordner wechseln und mit dem Befehl *Docker build* den Container erstellen.

```bash
docker build -t admidio_test .
```

### Container starten

Nach dem Erstellungsprozess kann man den Container mit folgendem Befehl starten (Provisionieren).

```bash
docker run -d -it --restart always --name admidio_test -p 8080:80 -v /var/adm_my_files:/var/www/admidio/adm_my_files -v /var/admidio_themes:/var/www/admidio/adm_themes -v /var/admidio_plugins:/var/www/admidio/adm_plugins admidio/admidio:v3.2.8
```

Danach über den Browser die Seite *http://localhost:8080/* aufrufen und das Admidio Setup durchgehen.

Falls man einen Docker basierte Datenbank hat, kann man die Datenbank mit dem Container verlinken und braucht nicht die IP-Addresse eingeben.

```bash
docker run -d -it --restart always --name admidio_test -p 8080:80 --link dockermysql:mysql -v /var/adm_my_files:/var/www/admidio/adm_my_files -v /var/admidio_themes:/var/www/admidio/adm_themes -v /var/admidio_plugins:/var/www/admidio/adm_plugins admidio/admidio:v3.2.8
```
Jetzt haben wir den Befehl *--link dockermysql:mysql* zum start hinzugegeben.

Dabei kann jetzt im Admidio Setup bei der Datenbank statt die IP-Addresse der Containername *dockermysql* eingeben werden und als Datenbank *mysql*.

### Erklärung zu dem Start Befehl

Bei diesem Beispiel

```bash
docker run -d -it --restart always --name admidio_test -p 8080:80 --link dockermysql:mysql -v /var/adm_my_files:/var/www/admidio/adm_my_files -v /var/admidio_themes:/var/www/admidio/adm_themes -v /var/admidio_plugins:/var/www/admidio/adm_plugins admidio/admidio:v3.2.8
```
* *--restart always* => auch nach einem Server Neustart den Container starten
* *--name* => gib dem Container einen Namen (sonst wird einer Automatisch generiert)
* *-p 8080:80* => Einen Port angeben, über dem man danach zugreifen kann (**lokal am Server**:**apache2 Port im Container**).
Dadurch könnte man z.B.: den Container auch über Port *8081* erreichen indem man es so angibt *-p 8081:80*.

Die Volume *-v* macht man aus dem Grund, damit man einfacher ein Backup bzw. Update durchführen kann.
Es ist aber kein muss.

* *-v /var/adm_my_files:/var/www/admidio/adm_my_files* => Uploads und config von Admidio Lokal in einen Ordner speichern.
* *-v /var/admidio_themes:/var/www/admidio/adm_themes* => Admidio Themes
* *-v /var/admidio_plugins:/var/www/admidio/adm_plugins => Admidio Plugins

**Info:** ~~es ist ein Mount Befehl, somit wird der Lokale Ordner am Host mit dem im Container drübergelegt.
Dies bedeutet: wenn der Lokale Ordner Leer ist, ist es auch im Container so.
Somit müsste man bei *adm_plugins*, *adm_themes* zuerst den Ordner am Lokalem Host anlegen und darin die Daten reinlegen.~~
Prüft ab jetzt automatisch und kopiert gegebenfalls vom Provisions Ordner.
Erklärung zu Docker Volume in diesem Beitrag [Docker Data Volumes](www.tricksofthetrades.net/2016/03/14/docker-data-volumes/)

* *--link dockermysql:mysql* => Docker Datenbank Server [MySQL](https://hub.docker.com/r/mysql/mysql-server/) oder [PostgreSQL](https://hub.docker.com/_/postgres/) mit dem Container Admidio verbinden. *dockermysql* = Name vom Docker Container, *mysql* = Name der Datenbank.
* *admidio/admidio:v3.2.8* => Image Name mit Versions Tag.

## Container updaten

Falls man es mit dem Docker Hub Repo verwendet, kann man folgende schritte durchführen.

* Download aktuelles Repo vom Docker Hub
```bash
docker pull admidio/admidio:latest
```
* Den aktuellen *Admidio_test* Container anhalten
```bash
docker stop admidio_test
```
* Container entfernen (Docker löscht dabei die Daten im *adm_my_files, admidio_themes und admidio_plugins* nicht)
```bash
docker rm admidio_test
```
* Mit folgendem Befehl den neuen Container Provisionieren und Starten (dabei kann der alte Befehl verwendet werden).
```bash
docker run -d -it --restart always --name admidio_test -p 8080:80 --link dockermysql:mysql -v /var/adm_my_files:/var/www/admidio/adm_my_files -v /var/admidio_themes:/var/www/admidio/adm_themes -v /var/admidio_plugins:/var/www/admidio/adm_plugins admidio/admidio:latest
```
* Über einen Browser auf die Admidio Seite gehen und wie im [Admidio Wiki die Migration](https://www.admidio.org/dokuwiki/doku.php?id=de:2.0:update) durchführen

### Container über Git updaten

Mit *Git pull* im aktuellen Ordner, das Git Repo runterladen und den Container neu Bauen.

```bash
git pull
```

```bash
docker build -t admidio_test .
```

Danach wendet man die gleichen Schritte an wie bei [*Container updaten*](#container-updaten), nur ohne den Download vom Docker Hub.

# Wiki zu Admidio

[Admidio Wiki](https://www.admidio.org/dokuwiki/doku.php?id=de:2.0:index)

# Zum Abschluss

Falls es Anregungen gibt, bitte über Github oder Dockerhub eine Anfrage erstellen.


# MySQL Benutzer und Datenbank in der MySQL Shell erstellen

```mysql
CREATE USER 'admidio'@'%' IDENTIFIED BY 'geheim';
CREATE DATABASE IF NOT EXISTS admidio;
GRANT ALL ON admidio.* TO 'admidio'@'%';
FLUSH PRIVILEGES;
quit;
```

# Docker Compose

Mit [*Docker-Compose*](https://docs.docker.com/compose/overview/) kann man sich die Container automatisch erstellen lassen und Verwalten.

Hier eine kleine Beispieldatei wie automatisch eine MySQL Datenbank erstellt wird und verlinkt auf den Admidio Container.

docker-compose.yaml
```yaml
version: '3'

services:
  mysql:
    restart: always
    image: mysql:5.6
    environment:
      - MYSQL_ROOT_PASSWORD=secret-password
      # mit diesen 3 zusätzlichen Zeilen wird eine Datenbank und Benutzer erstellt.
      - MYSQL_DATABASE=admidio
      - MYSQL_USER=admidio
      - MYSQL_PASSWORD=secret-password
    volumes:
      - <Lokaler-pfad-zum-Verzeichnis>/mysqlconfd:/etc/mysql/conf.d
      - <Lokaler-pfad-zum-Verzeichnis>/mysqldata:/var/lib/mysql
    ports:
      - 3306:3306


  admidio:
    restart: always
    image: admidio/admidio:v3.2
    depends_on:
      - mysql
    volumes:
      - <Lokaler-pfad-zum-Verzeichnis>/admidio_files:/var/www/admidio/adm_my_files
      - <Lokaler-pfad-zum-Verzeichnis>/admidio_plugins:/var/www/admidio/adm_plugins
      - <Lokaler-pfad-zum-Verzeichnis>/admidio_themes:/var/www/admidio/adm_themes
    ports:
      - 80:80

```

Mit dem folgendem Befehl werden die Container erstellt und als Dienst gestartet.
```bash
docker-compose up -d
```

Mit *docker-compose down* werden die Container beendet und gelöscht, die Volumes bleiben dabei erhalten.

Ein update kann auch mit *docker-compose up -d* gemacht werden, dabei wird geprüft ob sich etwas im docker-compose.yaml geändert hat, und 
gegebenfalls wird der jeweilige Container neu erstellt.

## Admidio mit Docker-Compose und SSL Reverse Proxy

Bei diesem Beispiel wird der [Nginx Proxy von jwilder](https://github.com/jwilder/nginx-proxy) mit [JrCs docker-letsencrypt-nginx-proxy-companion
](https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion) verwendet.

* Zuerst wird der Nginx Proxy und der Let's Encrypt dienst über docker-compose eingerichtet.
[Gist](https://gist.github.com/Brawn1/ace8599947b05520287f7ccf17944251)

```yaml
version: '2.0'

services:
  nginx-proxy:
    restart: always
    image: jwilder/nginx-proxy:latest
    ports:
      - '80:80'
      - '443:443'
    volumes:
      - nginxcerts:/etc/nginx/certs:ro
      - nginxvhostd:/etc/nginx/vhost.d
      - /usr/share/nginx/html
      - /var/run/docker.sock:/tmp/docker.sock:ro
      - nginxconfd:/etc/nginx/conf.d
    networks:
      - nginx-proxy

  letsencrypt-nginx-proxy-companion:
    restart: always
    image: jrcs/letsencrypt-nginx-proxy-companion
    # environment:  # remove this fake certificate in production
    # - ACME_CA_URI=https://acme-staging.api.letsencrypt.org/directory
    volumes:
      - nginxcerts:/etc/nginx/certs:rw
      - /var/run/docker.sock:/var/run/docker.sock:ro
    volumes_from:
      - nginx-proxy

networks:
  nginx-proxy:
    external: true

volumes:
  nginxcerts:
  nginxvhostd:
  nginxconfd:
```


* Danach kann Admidio mit einer Datenbank und einem extra Netzwerk eingerichtet werden.

```yaml
version: '3'

services:
  mysql:
    restart: always
    image: mysql:5.6
    environment:
      - MYSQL_ROOT_PASSWORD=secret-password
      # mit diesen 3 zusätzlichen Zeilen wird eine Datenbank und Benutzer erstellt.
      - MYSQL_DATABASE=admidio
      - MYSQL_USER=admidio
      - MYSQL_PASSWORD=secret-password
    volumes:
      - <Lokaler-pfad-zum-Verzeichnis>/mysqlconfd:/etc/mysql/conf.d
      - <Lokaler-pfad-zum-Verzeichnis>/mysqldata:/var/lib/mysql
    networks:
      - backend

  admidio:
    restart: always
    image: admidio/admidio:v3.2
    environment:
    # mit diesen 4 Variablen wird dem NGINX-Proxy die Notwendigen Infos übermittelt.
      - VIRTUAL_HOST=<Domain z.b.: admidio.example.com> # wird für Port 80 verwendet
      - LETSENCRYPT_HOST=<Domain z.b.: admidio.example.com> # wird für Port 443 verwendet und um das erstellen vom Zertifikat
      - LETSENCRYPT_EMAIL=office@example.com # wird für das erstellen vom Zertifikat verwendet
      - VIRTUAL_PROTO=http # Kommunikation zwischen Nginx-proxy und Admidio
    depends_on:
      - mysql
    networks:
    # zuweisung zu den Netzwerken.
      - backend
      - nginx-proxy
    volumes:
      - <Lokaler-pfad-zum-Verzeichnis>/admidio_files:/var/www/admidio/adm_my_files
      - <Lokaler-pfad-zum-Verzeichnis>/admidio_plugins:/var/www/admidio/adm_plugins
      - <Lokaler-pfad-zum-Verzeichnis>/admidio_themes:/var/www/admidio/adm_themes

networks:
  backend:
  nginx-proxy:
    external: true

```

Mit *docker-compose up -d* werden die Container erstellt und nach ein paar Sekunden ist Admidio über admidio.example.com per HTTPS erreichbar.
Der HTTP verkehr wird automatisch auf HTTPS umgeleitet.

