# Supported tags and respective `Dockerfile` links

- `latest`, `1`, `1.4`, `1.4.10` [(Dockerfile)](https://github.com/machine-data/docker-oauth2_proxy/blob/master/Dockerfile)

- `1.4.8` [(Dockerfile)](https://github.com/machine-data/docker-node-red/blob/v1.4.8-r2/Dockerfile)

# Mosquitto on Docker

This repository holds a build definition and supporting files for building a Docker image to run [Mosquitto](https://mosquitto.org).
It is published as automated build `machine-data/mosquitto` on [Docker Hub](https://registry.hub.docker.com/u/machinedata/mosquitto/).

## What is Mosquitto?

[Mosquitto](https://mosquitto.org) is an open source (EPL/EDL licensed) message broker that implements the MQTT protocol versions 3.1 and 3.1.1. MQTT provides a lightweight method of carrying out messaging using a publish/subscribe model. This makes it suitable for "Internet of Things" messaging such as with low power sensors or mobile devices such as phones, embedded computers or microcontrollers like the Arduino.

## Yet another Mosquitto container?

Not quite:
- Based on the official Alpine Linux image - super slim and lightweight.
- No magic. Straight config that follows upstream. Simple and clean configuration via environment variables _or_ config file.
- Image follows [Dockerfile best practices](https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/) (dropping root privileges, PID1 for proper signalling, logging,...)
- All user data under `/data` - ready-to mount.

## Quickstart

Start Mosquitto and name the container `mosquitto_test`:

```sh
$ docker run -d \
    --name mosquitto_test \
    machine-data/mosquitto
```

Push a message to the broker:

```sh
$ docker run \
    --rm -ti \
    --link mosquitto_test \
    machine-data/mosquitto \
    mosquitto_pub \
        -h mosquitto_test \
        -t "mytopic/mypath" \
        -m "message payload" \
        -q 1 -r
```

Consume one message from the broker:

```sh
$ docker run \
    --rm -ti \
    --link mosquitto_test:mosquitto \
    machine-data/mosquitto \
    mosquitto_sub \
        -h localhost \
        -t "mytopic/mypath" \
        -C 1
```

If Mosquitto ends, it will save the in-memory database to the `/data` directory, therefore it is recommended to bind mount a volume.

```sh
$ mkdir data
$ docker run -d \
    --volume $(pwd)/data:/data \
    --publish 1880:1880 \
    machine-data/mosquitto
```

## Environment variables

It is very easy to configure Mosquitto via environment variables. If no config file is present, the `docker-entrypoint.sh` script will create one based on sane defaults and environment variables.

- `MOSQUITTO_LOG_DEST`: Change this from the default `stdout` if you like the logs being written to disk.

- `MOSQUITTO_PERSISTENCE`: Save persistent message data to disk (true/false). Default: true

- `MOSQUITTO_PERSISTENCE_LOCATION`: The directory where the in-memory database is being saved. This translates to `persistence_location` in `mosquitto.conf`. In most cases it makes sense to keep the `/data` default.

## Configuration file

The container is configured to start Mosquitto with `/config/mosquitto.conf` as config file.
If a config file (or the entire /config directory) is mounted (preferably read-only), the `MOSQUITTO_` environment variables will be ignored:

```sh
$ curl -O https://raw.githubusercontent.com/eclipse/mosquitto/master/mosquitto.conf
$ sed -e "s#log_dest syslog#log_dest stdout#" \
      -e "s#\#persistence false#persistence true#" \
      -e "s#\#persistence_location#persistence_location /data#" \

$ docker run -d \
             -v $(pwd)/mosquitto.conf:/config/mosquitto.conf:ro \
             -p 1883:1883 machine-data/mosquitto
```

## Volumes

- `/data`: Path where Mosquitto's in-memory database id being saved.

## Ports

- `1883`: Port for the default listener

- `8883`: Recommended port for MQTT over TLS, needs to be set manually

- `9001`: Websocket listener port, needs to be set manually

## Legal

Mosquitto was written by Roger Light roger@atchoo.org and is [dual licensed](https://github.com/eclipse/mosquitto/blob/master/LICENSE.txt) under the Eclipse Public License 1.0 and the Eclipse Distribution License 1.0.
Copyright (c) 2007, Eclipse Foundation, Inc. and its licensors.

docker-mosquitto is licensed under the [Apache 2.0 license](https://github.com/machine-data/mosquitto/blob/master/LICENSE), was created by [Jodok Batlogg](https://github.com/jodok).
Copyright 2016-2017 [Crate.io, Inc.](https://crate.io).

## Contributing

Thanks for considering contributing to docker-mosquitto!
The easiest way to contribute is either by filing an [issue on Github](https://github.com/machine-data/docker-mosquitto/issues) or to [fork the repository](https://github.com/machine-data/docker-mosquitto/fork) to create a pull request.

If you have any questions don't hesitate to join us on Slack.
