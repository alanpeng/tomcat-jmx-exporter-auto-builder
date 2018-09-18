FROM tomcat:latest
COPY catalina.sh /usr/local/tomcat/bin/
COPY tomcat-jmx-exporter.yml /usr/local/tomcat/
COPY jmx_prometheus_javaagent.jar /usr/local/tomcat/
