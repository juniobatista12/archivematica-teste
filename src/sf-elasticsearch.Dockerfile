FROM docker.elastic.co/elasticsearch/elasticsearch:6.8.0

WORKDIR /usr/share/elasticsearch

COPY sf-elastic-entry.sh .
RUN chmod +x sf-elastic-entry.sh
ENTRYPOINT /usr/share/elasticsearch/sf-elastic-entry.sh
