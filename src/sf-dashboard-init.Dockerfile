FROM registry.senado.leg.br/adm/archivematica/archivematica-dashboard:1.12.1-sf01

ENV DEBIAN_FRONTEND noninteractive
ENV DJANGO_SETTINGS_MODULE settings.production
ENV PYTHONPATH /src/dashboard/src/:/src/archivematicaCommon/lib/
ENV PYTHONUNBUFFERED 1
ENV AM_GUNICORN_BIND 0.0.0.0:8000
ENV AM_GUNICORN_CHDIR /src/dashboard/src
ENV FORWARDED_ALLOW_IPS *

# Set the locale
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

USER root
COPY ./archivematica-mcp-dashboard-init.sh /src/dashboard
RUN chmod +x /src/dashboard/archivematica-mcp-dashboard-init.sh

# USER archivematica

EXPOSE 8000

ENTRYPOINT /src/dashboard/archivematica-mcp-dashboard-init.sh
