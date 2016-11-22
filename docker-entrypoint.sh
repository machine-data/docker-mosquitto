#!/bin/sh
set -e

# first arg is `-f` or `--some-option`
if [ "${1:0:1}" = '-' ]; then
    set -- mosquitto "$@"
fi

# allow the container to be started with `--user`
if [ "$1" = 'mosquitto' -a "$(id -u)" = '0' ]; then
    chown -R mosquitto:mosquitto /config /data
    exec su-exec mosquitto "$0" "$@"
fi

if [ "$1" = 'mosquitto' ]; then

    # if undefined, populate environment variables with sane defaults
    : ${MOSQUITTO_LOG_DEST=stdout}
    : ${MOSQUITTO_PERSISTENCE=true}
    : ${MOSQUITTO_PERSISTENCE_LOCATION=/data}
    : ${MOSQUITTO_PID_FILE=/var/run/mosquitto.pid}

    # if no configfile is provided, generate one based on the environment variables
    if [ ! -f /config/mosquitto.conf ]; then

        # use dist config file and replace settings
        sed -e "s#log_dest syslog#log_dest $MOSQUITTO_LOG_DEST#" \
            -e "s#\#persistence false#persistence $MOSQUITTO_PERSISTENCE#" \
            -e "s#\#persistence_location#persistence_location $MOSQUITTO_PERSISTENCE_LOCATION#" \
            -e "s#\#pid_file#pid_file $MOSQUITTO_PID_FILE#" \
            \
            /config/mosquitto.conf.dist > /config/mosquitto.conf
    fi
fi

exec "$@"
