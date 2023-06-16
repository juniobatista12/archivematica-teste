FROM archivematica-base:1.13.2

USER archivematica

ENV DJANGO_SETTINGS_MODULE settings.common
ENV PYTHONPATH /src/src/MCPServer/lib/:/src/src/archivematicaCommon/lib/:/src/src/dashboard/src/

ENTRYPOINT ["/src/src/MCPServer/lib/archivematicaMCP.py"]