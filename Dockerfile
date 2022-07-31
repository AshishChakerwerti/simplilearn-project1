# we have to run from jenkins server
FROM httpd:2.4
MAINTAINER Ashish
COPY ./index.html /usr/local/apache2/htdocs/
EXPOSE 80