# Prometheus Cloud Foundry App

## Deploying

Push the app (without starting it)
```bash
cf push --no-start
```

Set the required environmental variables
```bash
cf set-env prometheus BROKER_URL <url>
cf set-env prometheus BROKER_USERNAME <username>
cf set-env prometheus BROKER_PASSWORD <password>
```

Start the app:
```bash
cf start prometheus
```
