#!/bin/bash -e
echo "Starting goaccess for the following files:"
find /srv/logs/ -name "default-host_access*.log*" -print
zcat /srv/logs/default-host_access.*.gz | goaccess /srv/logs/default-host_access.log --no-global-config --config-file=/srv/config/goaccess.conf
exit 0