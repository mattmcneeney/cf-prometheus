#!/bin/bash

./generate-configuration.sh &
./prometheus --config.file=prometheus.yml --web.listen-address=':8080' --web.enable-lifecycle

