FROM adoptopenjdk/openjdk11
RUN mkdir /opt/tomcat/

WORKDIR /opt/tomcat
RUN curl -O https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.82/bin/apache-tomcat-9.0.82.tar.gz
RUN tar xvfz apache*.tar.gz
RUN mv apache-tomcat-9.0.82/* /opt/tomcat/.

VOLUME /opt/tomcat/props
VOLUME /opt/tomcat/axelor

COPY build/libs/axelor-erp-*.war /opt/tomcat/webapps/ROOT.war
RUN rm -rf /opt/tomcat/webapps/ROOT
EXPOSE 8080

# Install system dependencies
ENV GCSFUSE_VERSION=1.2.0

RUN set -e; \
    apt-get update -y && apt-get install -y \
    gnupg2 \
    tini \
    lsb-release; \
    apt-get update -y && \
    curl -LJO "https://github.com/GoogleCloudPlatform/gcsfuse/releases/download/v${GCSFUSE_VERSION}/gcsfuse_${GCSFUSE_VERSION}_amd64.deb" && \
    apt-get -y install fuse && \
    apt-get clean && \
    dpkg -i "gcsfuse_${GCSFUSE_VERSION}_amd64.deb"

# Set fallback mount directory
ENV MNT_DIR /mnt/gcs
ENV JAVA_OPTS="-Daxelor.config=/opt/tomcat/props/application.properties"

# Copy the jar to the production image from the builder stage.

# Copy the statup script
COPY gcsfuse_run.sh ./gcsfuse_run.sh
RUN chmod +x ./gcsfuse_run.sh

# Use tini to manage zombie processes and signal forwarding
# https://github.com/krallin/tini
ENTRYPOINT ["/usr/bin/tini", "--"]
RUN ls
# Run the web service on container startup.
CMD ["./gcsfuse_run.sh"]