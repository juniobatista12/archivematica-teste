FROM nginx:1.20.1-alpine

# Set the locale
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

USER root
WORKDIR /etc/nginx

COPY ./sf-nginx/nginx.conf nginx.conf
COPY ./sf-nginx/conf.d/archivematica.conf conf.d/archivematica.conf
COPY ./sf-nginx/conf.d/default.conf conf.d/default.conf

EXPOSE 80

STOPSIGNAL SIGQUIT
