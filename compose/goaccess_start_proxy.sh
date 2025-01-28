#!/bin/bash -e
echo "Starting goaccess for the following files:"
find /srv/logs/ -name "proxy-host-*access*.log*" -print
zcat /srv/logs/proxy-host-*access*.log*.gz | goaccess $(find /srv/logs/ -name "proxy-host-*access*.log" -print) --no-global-config --config-file=/srv/config/goaccess.conf
exit 0