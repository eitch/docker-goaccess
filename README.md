# docker-goaccess

This is a fork of https://github.com/jakubstrama/docker-goaccess

This is an Alpine linux container which builds GoAccess including GeoIP. It reverse proxies the GoAccess HTML files and
websockets through nginx, allowing GoAccess content to be viewed without any other setup.

# Version

- 1.9.4

# Usage

## Example docker build and push

```
# prepare
goaccess_version="1.9.4"
geolite_version="2"
geolite_city_link="XXX"

# build
docker build --build-arg geolite_city_link=$geolite_city_link --build-arg geolite_version=$geolite_version -t docker-goaccess:${goaccess_version} .
# for use locally
docker tag docker-goaccess:${goaccess_version} eitch/docker-goaccess:${goaccess_version}
docker tag docker-goaccess:${goaccess_version} eitch/docker-goaccess:latest

# push remote
docker login repo.strolch.li
docker tag docker-goaccess:${goaccess_version} repo.strolch.li/docker/docker-goaccess:${goaccess_version}
docker tag docker-goaccess:${goaccess_version} repo.strolch.li/docker/docker-goaccess:latest
docker push repo.strolch.li/docker/docker-goaccess:${goaccess_version}
docker push repo.strolch.li/docker/docker-goaccess:latest
```

## Docker pull

```
docker pull eitch/docker-goaccess
```

## Example docker run

```
docker run --rm --name goaccess -p 7889:7889 -v $PWD/logs:/srv/logs -v $PWD/public:/srv/report -v $PWD/configs/goaccess.default.conf:/config/goaccess.conf eitch/docker-goaccess
docker run --rm --name goaccess -p 7889:7889 -v $PWD/logs:/srv/logs -v $PWD/public:/srv/report -v $PWD/configs/goaccess.proxy.conf:/config/goaccess.conf eitch/docker-goaccess
```

## Volume Mounts

- /srv/report
    - GoAccess generated files and nginx root
- /logs
    - Map to nginx log directory

## Variables

**none**

## Files

- /config/goaccess.conf
    - GoAccess config file (populated with default config unless modified)
- /srv/report
    - GoAccess generated static HTML

# Generate the list of log files:

```bash
for f in proxy-*-access.log ; do echo log-file /srv/logs/$(basename $f) | sort ; done
```

The result can be copied into the configuration file

## Reverse Proxy

### nginx

```
location ^~ /goaccess {
    resolver 127.0.0.11 valid=30s;
    set $upstream_goaccess goaccess;
    proxy_pass http://$upstream_goaccess:7889/;

    proxy_connect_timeout 1d;
    proxy_send_timeout 1d;
    proxy_read_timeout 1d;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "Upgrade";
}
```
