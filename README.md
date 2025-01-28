# docker-goaccess

This is a fork of https://github.com/jakubstrama/docker-goaccess

This is an Alpine linux container which builds GoAccess including GeoIP. It reverse proxies the GoAccess HTML files and websockets through nginx, allowing GoAccess content to be viewed without any other setup.

# Version

- 1.9.3

# Usage

## Example docker build and push

```
geolite_version="XX"
geolite_city_link="XXX"
docker build --build-arg geolite_city_link=$geolite_city_link --build-arg geolite_version=$geolite_version -t docker-goaccess:1.9.3 .
# for use locally
docker tag docker-goaccess:1.9.3 eitch/docker-goaccess:1.9.3
docker tag docker-goaccess:1.9.3 eitch/docker-goaccess:latest

# push remote
docker login repo.strolch.li
sudo docker tag docker-goaccess:1.9.3 repo.strolch.li/docker/docker-goaccess:1.9.3
sudo docker tag docker-goaccess:1.9.3 repo.strolch.li/docker/docker-goaccess:latest
sudo docker push repo.strolch.li/docker/docker-goaccess:1.9.3
sudo docker push repo.strolch.li/docker/docker-goaccess:latest
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
