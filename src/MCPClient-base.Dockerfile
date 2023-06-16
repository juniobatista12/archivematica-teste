FROM ubuntu:18.04

ENV DEBIAN_FRONTEND noninteractive
ENV PYTHONUNBUFFERED 1

RUN set -ex \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \
		apt-transport-https \
		curl \
		gettext \
		git \
		gpg-agent \
		locales \
		software-properties-common \
	&& rm -rf /var/lib/apt/lists/*

# Set the locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# OS dependencies
COPY utils/osdeps.py /src/hack/osdeps.py
COPY dashboard/osdeps /src/src/dashboard/osdeps
COPY MCPServer/osdeps /src/src/MCPServer/osdeps
COPY MCPClient/osdeps /src/src/MCPClient/osdeps
RUN set -ex \
	&& curl -s https://packages.archivematica.org/GPG-KEY-archivematica | apt-key add - \
	&& add-apt-repository --no-update --yes "deb [arch=amd64] http://packages.archivematica.org/1.13.x/ubuntu-externals bionic main" \
	&& add-apt-repository --no-update --yes "deb http://archive.ubuntu.com/ubuntu/ bionic multiverse" \
	&& add-apt-repository --no-update --yes "deb http://archive.ubuntu.com/ubuntu/ bionic-security universe" \
	&& add-apt-repository --no-update --yes "deb http://archive.ubuntu.com/ubuntu/ bionic-updates multiverse" \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \
		build-essential libyaml-dev clamav \
	&& /src/hack/osdeps.py Ubuntu-18 1 | grep -v -E "nginx|postfix" | xargs apt-get install -y --no-install-recommends \
	&& rm -rf /var/lib/apt/lists/*

# Download ClamAV virus signatures
RUN freshclam --quiet

# Install Node.js and Yarn
RUN set -ex \
	&& curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
	&& add-apt-repository --yes "deb https://dl.yarnpkg.com/debian/ stable main" \
	&& apt-get install -y --no-install-recommends \
		yarn nodejs \
	&& rm -rf /var/lib/apt/lists/*

RUN set -ex \
	&& groupadd --gid 333 --system archivematica \
	&& useradd -m --uid 333 --gid 333 --system archivematica

RUN set -ex \
	&& mkdir -p /var/archivematica/sharedDirectory \
	&& chown -R archivematica:archivematica /var/archivematica

RUN set -ex \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \
		python3-dev libmysqlclient-dev libsasl2-dev python-dev libldap2-dev libssl-dev \
	&& rm -rf /var/lib/apt/lists/*

RUN set -ex \
	&& curl -s https://bootstrap.pypa.io/pip/3.6/get-pip.py | python3.6 \
	&& update-alternatives --install /usr/bin/python python /usr/bin/python3 10

COPY utils/requirements-dev-py3.txt /src/requirements-dev-py3.txt
RUN pip3 install -r /src/requirements-dev-py3.txt

COPY MCPServer /src/src/MCPServer
COPY MCPClient /src/src/MCPClient
COPY dashboard /src/src/dashboard
COPY archivematicaCommon /src/src/archivematicaCommon