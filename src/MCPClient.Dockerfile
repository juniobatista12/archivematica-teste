FROM registry.senado.leg.br/adm/archivematica/archivematica-mcp-client-base:1.13.2

ENV DJANGO_SETTINGS_MODULE settings.common
ENV PYTHONPATH /src/MCPClient/lib/:/src/archivematicaCommon/lib/:/src/dashboard/src/
ENV ARCHIVEMATICA_MCPCLIENT_MCPCLIENT_ARCHIVEMATICACLIENTMODULES /src/MCPClient/lib/archivematicaClientModules
ENV ARCHIVEMATICA_MCPCLIENT_MCPCLIENT_CLIENTASSETSDIRECTORY /src/MCPClient/lib/assets/
ENV ARCHIVEMATICA_MCPCLIENT_MCPCLIENT_CLIENTSCRIPTSDIRECTORY /src/MCPClient/lib/clientScripts/

COPY requirements.txt /
RUN pip install -r /requirements.txt

COPY archivematicaCommon/ /src/archivematicaCommon/
COPY dashboard/ /src/dashboard/
COPY MCPClient/ /src/MCPClient/

# Some scripts in archivematica-fpr-admin executed by MCPClient rely on certain
# files being available in this image (e.g. see https://git.io/vA1wF).
COPY archivematicaCommon/lib/externals/fido/ /usr/lib/archivematica/archivematicaCommon/externals/fido/
COPY archivematicaCommon/lib/externals/fiwalk_plugins/ /usr/lib/archivematica/archivematicaCommon/externals/fiwalk_plugins/


USER archivematica

ENTRYPOINT ["/src/MCPClient/lib/archivematicaClient.py"]
