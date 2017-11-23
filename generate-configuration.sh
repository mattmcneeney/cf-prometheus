#!/bin/bash

while true
do

    CONFIG_FILE=prometheus.yml
    TEMP_CONFIG_FILE=temp.yml
    rm -f $TEMP_CONFIG_FILE

    # Global configuration
    GLOBAL_CONFIG="
    global:\n
      scrape_interval:     15s\n
      evaluation_interval: 15s\n
    "
    echo -e $GLOBAL_CONFIG > $TEMP_CONFIG_FILE

    # List service instances
    SERVICES=$(curl -s "http://admin:password@overview-broker.services-api-product.cf-app.com/v2/service_instances")
    SERVICE_INSTANCE_IDS=($(echo $SERVICES | jq 'keys[]'))

    # Add scrape configs section if we have instances
    if [ ${#SERVICES[@]} -gt 0 ]; then
       echo -e "scrape_configs:" >> $TEMP_CONFIG_FILE
    fi

    for id in "${SERVICE_INSTANCE_IDS[@]}"
    do
        URL=$(echo $SERVICES | jq .[$id].metrics_url)
        METRICS_PATH=$(echo $URL | cut -d "/" -f 4-)
        TARGET=$(echo $URL | cut -d "/" -f 3)
        echo "  - job_name: $id" >> $TEMP_CONFIG_FILE
        echo "    scheme: \"https\"" >> $TEMP_CONFIG_FILE
        echo "    metrics_path: \"/$METRICS_PATH" >> $TEMP_CONFIG_FILE
        echo "    tls_config:" >> $TEMP_CONFIG_FILE
        echo "      insecure_skip_verify: true" >> $TEMP_CONFIG_FILE
        echo "    static_configs:" >> $TEMP_CONFIG_FILE
        echo "      - targets: [\"$TARGET\"]" >> $TEMP_CONFIG_FILE
    done

    if diff $CONFIG_FILE $TEMP_CONFIG_FILE > /dev/null 2>&1
    then
        echo "Configuration unchanged"
    else
        echo "Configuration has changed"
        cp $TEMP_CONFIG_FILE $CONFIG_FILE

        # Reload prometheus
        curl -s -X POST http://localhost:8080/-/reload &&
        echo "Prometheus reloaded"
    fi

    sleep 10
done
