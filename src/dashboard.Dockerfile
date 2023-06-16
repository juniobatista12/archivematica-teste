FROM archivematica-base:1.13.2

RUN set -ex \
	&& internalDirs=' \
		/src/src/dashboard/src/static \
		/src/src/dashboard/src/media \
	' \
	&& mkdir -p $internalDirs \
	&& chown -R archivematica:archivematica $internalDirs \
	&& yarn --cwd=/src/src/dashboard/frontend install --frozen-lockfile

WORKDIR /src/src/dashboard/src

USER archivematica

ENV DJANGO_SETTINGS_MODULE settings.local
ENV PYTHONPATH /src/src/dashboard/src/:/src/src/archivematicaCommon/lib/
ENV AM_GUNICORN_BIND 0.0.0.0:8000
ENV AM_GUNICORN_CHDIR /src/src/dashboard/src
ENV FORWARDED_ALLOW_IPS *

RUN set -ex \
	&& ./manage.py collectstatic --noinput --clear \
	&& ./manage.py compilemessages

ENV DJANGO_SETTINGS_MODULE settings.production

EXPOSE 8000

ENTRYPOINT ["/usr/local/bin/gunicorn", "--config=/src/src/dashboard/install/dashboard.gunicorn-config.py", "wsgi:application"]