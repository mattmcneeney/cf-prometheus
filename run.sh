#!/bin/bash

# Check for required environmental variables
if [ -z $BROKER_URL ]; then
    echo "Missing BROKER_URL environmental varaible"
    exit 1
fi
if [ -z $BROKER_USERNAME ]; then
    echo "Missing BROKER_USERNAME environmental varaible"
    exit 1
fi
if [ -z $BROKER_PASSWORD ]; then
    echo "Missing BROKER_PASSWORD environmental varaible"
    exit 1
fi
./generate-configuration.sh &
./prometheus --config.file=prometheus.yml --web.listen-address=':8080' --web.enable-lifecycle
