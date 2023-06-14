FROM archivematica-base:latest

ENV DEBIAN_FRONTEND noninteractive
ENV DJANGO_SETTINGS_MODULE settings.common
ENV PYTHONPATH /src/MCPServer/lib/:/src/archivematicaCommon/lib/:/src/dashboard/src/
ENV PYTHONUNBUFFERED 1

RUN set -ex \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \
		gettext \
		default-libmysqlclient-dev \
		libldap2-dev \
		libsasl2-dev \
		locales \
		locales-all \
		python \
	&& rm -rf /var/lib/apt/lists/*

# Set the locale
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

COPY requirements.txt /
RUN pip install -r /requirements.txt

COPY archivematicaCommon/ /src/archivematicaCommon/
COPY dashboard/ /src/dashboard/
COPY MCPServer/ /src/MCPServer/
COPY checkformigrations.sh /

RUN chmod +x checkformigrations.sh

RUN set -ex \
	&& mkdir -p /var/archivematica/sharedDirectory \
	&& chown -R archivematica:archivematica /var/archivematica

RUN find / -type f -name \*.py -exec chmod +x '{}' \;

RUN chmod +x /src/MCPServer/lib/archivematicaMCP.py

USER archivematica

ENTRYPOINT ["/src/MCPServer/lib/archivematicaMCP.py"]
