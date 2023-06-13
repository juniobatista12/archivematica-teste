FROM docker.elastic.co/elasticsearch/elasticsearch:6.8.0
WORKDIR /usr/share/elasticsearch
USER root
RUN yum install zip -y
RUN zip -q -d /usr/share/elasticsearch/lib/log4j-core-*.jar org/apache/logging/log4j/core/lookup/JndiLookup.class
USER elasticsearch