# Tomcat-JMX-Exporter-Auto-Builder
Build tomcat docker image with Prometheus JMX Exporter

### Modify the version number for your needs in the file build-tomcat-jmx-exporter.sh
```
#!/bin/bash
set -e
TOMCAT_VERSION_TAG=7.0
JMX_AGENT_VERSION=0.3.1
JMX_AGENT_PORT=8686
```
### Execute the script
```
./build-tomcat-jmx-exporter.sh
```
You will get the new image: tomcat-with-jmx-exporter:$TOMCAT_VERSION_TAG

### How to use this docker image
```
docker run -d --name=tomcat-exporter -p 8686:8686 tomcat-with-jmx-exporter:7.0
```
Metrics for Prometheus will now be accessible at http://localhost:8686/metrics
