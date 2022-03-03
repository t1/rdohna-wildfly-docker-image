ARG WILDFLY_VERSION=26.0.1.Final
ARG JDK_VERSION=11
FROM eclipse-temurin:${JDK_VERSION}
LABEL maintainer=https://github.com/t1 license=Apache-2.0 name='' build-date='' vendor=''

# this path is also in ENTRYPOINT below
ENV JBOSS_HOME /opt/jboss/wildfly

# Ensure signals are forwarded to the JVM process correctly for graceful shutdown
ENV LAUNCH_JBOSS_IN_BACKGROUND true

USER root
RUN addgroup --system --gid 1000 wildfly && \
    adduser --system --home $JBOSS_HOME --uid 1000 -gid 1000 wildfly

USER wildfly
WORKDIR $JBOSS_HOME
RUN WILDFLY=wildfly-${WILDFLY_VERSION} && \
    curl -L -O https://github.com/wildfly/wildfly/releases/download/${WILDFLY_VERSION}/${WILDFLY}.tar.gz && \
    tar xf ${WILDFLY}.tar.gz && \
    mv ${WILDFLY}/* . && \
    mv ${WILDFLY}/.installation . && \
    mv ${WILDFLY}/.well-known . && \
    rm ${WILDFLY}.tar.gz && \
    rmdir ${WILDFLY}

COPY setup.cli $JBOSS_HOME/setup.cli
RUN $JBOSS_HOME/bin/jboss-cli.sh --file=setup.cli && \
    rm -r setup.cli $JBOSS_HOME/standalone/configuration/standalone_xml_history

#      app  dbg  adm
EXPOSE 8080 8787 9990
# this path is also in JBOSS_HOME above
ENTRYPOINT ["/opt/jboss/wildfly/bin/standalone.sh"]
CMD ["--debug", "--read-only-server-config=standalone.xml", "-b=0.0.0.0", "-bmanagement=0.0.0.0"]
