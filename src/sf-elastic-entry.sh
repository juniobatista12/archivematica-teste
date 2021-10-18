#!/bin/bash
id
sysctl -w vm.max_map_count=262144
exec /usr/local/bin/docker-entrypoint.sh