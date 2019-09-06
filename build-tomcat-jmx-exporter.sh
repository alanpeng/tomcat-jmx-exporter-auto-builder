#!/bin/bash
set -e
TOMCAT_VERSION_TAG=7.0
JMX_AGENT_VERSION=0.3.1
JMX_AGENT_PORT=8686
JMX_AGENT_URL="https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/$JMX_AGENT_VERSION/jmx_prometheus_javaagent-$JMX_AGENT_VERSION.jar"
TOMCAT_CONFIG_YAML_URL="https://raw.githubusercontent.com/prometheus/jmx_exporter/master/example_configs/tomcat.yml"

TIME_STRING=`date +%Y%m%d%H%M%S`
TEMP_CONTAINER_NAME=tomcat-$TIME_STRING

# Get catalina.sh
docker pull tomcat:$TOMCAT_VERSION_TAG
docker run -d --name=$TEMP_CONTAINER_NAME tomcat:$TOMCAT_VERSION_TAG
rm -rf DockerBuild-$TIME_STRING
mkdir DockerBuild-$TIME_STRING
docker cp $TEMP_CONTAINER_NAME:/usr/local/tomcat/bin/catalina.sh DockerBuild-$TIME_STRING
docker stop $TEMP_CONTAINER_NAME
docker rm $TEMP_CONTAINER_NAME

### Modify catalina.sh
# Find the line number
line=`grep -n 'JAVA_OPTS="$JAVA_OPTS $JSSE_OPTS"' DockerBuild-$TIME_STRING/catalina.sh |awk -F ":" '{print $1}'`
# Add a line
sed -i -e "$line r tomcat-jmx-config-string.txt" DockerBuild-$TIME_STRING/catalina.sh
# Replace the port number
sed -i -e 's#$JMX_PORT#'"$JMX_AGENT_PORT"'#g' DockerBuild-$TIME_STRING/catalina.sh

# Get tomcat-jmx-exporter.yaml and jmx_prometheus_javaagent.jar
curl -L -o DockerBuild-$TIME_STRING/tomcat-jmx-exporter.yml $TOMCAT_CONFIG_YAML_URL
curl -L -o DockerBuild-$TIME_STRING/jmx_prometheus_javaagent.jar $JMX_AGENT_URL

# Modify Dockerfile
cp Dockerfile DockerBuild-$TIME_STRING
sed -i -e 's#latest#'"$TOMCAT_VERSION_TAG"'#g' DockerBuild-$TIME_STRING/Dockerfile

cd DockerBuild-$TIME_STRING
docker build -t tomcat-with-jmx-exporter:$TOMCAT_VERSION_TAG .

cd ..
rm -rf DockerBuild-$TIME_STRING
