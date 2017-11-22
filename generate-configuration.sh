#!/bin/bash

CONFIG_FILE=prometheus.yml
rm -f $CONFIG_FILE

GLOBAL_CONFIG="
global:\n
  scrape_interval:     15s\n
  evaluation_interval: 15s\n
"
echo -e $GLOBAL_CONFIG > $CONFIG_FILE

METRICS_URLS=($(cf curl /v2/service_instances | grep metrics_url | cut -d '"' -f 4 | tr " " "\n"))

if [ ${#METRICS_URLS[@]} -eq 0 ]; then
   exit 0
fi

echo -e "scrape_configs:" >> $CONFIG_FILE

for url in "${METRICS_URLS[@]}"
do
   ID="$(echo $url | cut -d "/" -f 6)"
   METRICS_PATH=$(echo $url | cut -d "/" -f 4-)
   TARGET=$(echo $url | cut -d "/" -f 3)
   echo "  - job_name: '$ID'" >> $CONFIG_FILE
   echo "    scheme: 'https'" >> $CONFIG_FILE
   echo "    metrics_path: /$METRICS_PATH" >> $CONFIG_FILE
   echo "    tls_config:" >> $CONFIG_FILE
   echo "      insecure_skip_verify: true" >> $CONFIG_FILE
   echo "    static_configs:" >> $CONFIG_FILE
   echo "      - targets: ['$TARGET']" >> $CONFIG_FILE
done

