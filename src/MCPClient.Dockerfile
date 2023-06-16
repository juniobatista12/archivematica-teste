FROM archivematica-base:1.13.2

# Some scripts in archivematica-fpr-admin executed by MCPClient rely on certain
# files being available in this image (e.g. see https://git.io/vA1wF).
COPY archivematicaCommon/lib/externals/fido/ /usr/lib/archivematica/archivematicaCommon/externals/fido/
COPY archivematicaCommon/lib/externals/fiwalk_plugins/ /usr/lib/archivematica/archivematicaCommon/externals/fiwalk_plugins/

USER archivematica

ENV DJANGO_SETTINGS_MODULE settings.common
ENV PYTHONPATH /src/src/MCPClient/lib/:/src/src/MCPClient/lib/clientScripts:/src/src/archivematicaCommon/lib/:/src/src/dashboard/src/
ENV ARCHIVEMATICA_MCPCLIENT_ARCHIVEMATICACLIENTMODULES /src/src/MCPClient/lib/archivematicaClientModules
ENV ARCHIVEMATICA_MCPCLIENT_CLIENTASSETSDIRECTORY /src/src/MCPClient/lib/assets/
ENV ARCHIVEMATICA_MCPCLIENT_CLIENTSCRIPTSDIRECTORY /src/src/MCPClient/lib/clientScripts/

ENTRYPOINT ["/src/src/MCPClient/lib/archivematicaClient.py"]
