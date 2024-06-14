#!/usr/bin/env bash

if [ $HOSTNAME = "clio" ]; then
    rippled_ip=$(getent hosts rippled | awk '{ print $1 }')
    sed "s/RIPPLED_IP/$rippled_ip/" /opt/clio/etc/config.json > /tmp/config.json
    /opt/clio/bin/clio_server /tmp/config.json
elif [ $HOSTNAME = "rippled" ]; then
    rippled_ip=$(getent hosts rippled | awk '{ print $1 }')
    ip_prefix=$(echo $rippled_ip | cut -d . -f 1-3)
    clio_octet=$(($(echo $rippled_ip | cut -d . -f 4) + 2 )) # scylla will start first
    clio_ip="${ip_prefix}.${clio_octet}"
    sed "s/CLIO_IP/$clio_ip/" /opt/ripple/etc/rippled.cfg > /tmp/rippled.cfg
    cp /opt/ripple/etc/validators.txt /tmp/validators.txt
    rippled --conf /tmp/rippled.cfg
fi
