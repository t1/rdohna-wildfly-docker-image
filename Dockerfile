ARG JDK_VERSION
FROM eclipse-temurin:${JDK_VERSION}
ARG WILDFLY_VERSION
ARG POSTGRESQL_VERSION
LABEL maintainer=https://github.com/t1 license=Apache-2.0

# this path is also in ENTRYPOINT below
ENV JBOSS_HOME=/opt/jboss/wildfly

# Ensure signals are forwarded to the JVM process correctly for graceful shutdown
ENV LAUNCH_JBOSS_IN_BACKGROUND=true

USER root
RUN addgroup --system --gid 1000 wildfly && \
    adduser --system --home ${JBOSS_HOME} --uid 1000 -gid 1000 wildfly

USER wildfly
WORKDIR ${JBOSS_HOME}
RUN echo "alias l='ls -lahF'" >> .bashrc && \
    curl -L -O https://github.com/wildfly/wildfly/releases/download/${WILDFLY_VERSION}/wildfly-${WILDFLY_VERSION}.tar.gz
# a separate layer for easier playing around with the unpacking
RUN tar xf wildfly-${WILDFLY_VERSION}.tar.gz && \
    mv wildfly-${WILDFLY_VERSION}/* . && \
    mv wildfly-${WILDFLY_VERSION}/.installation . && \
    mv wildfly-${WILDFLY_VERSION}/.well-known . && \
    rm wildfly-${WILDFLY_VERSION}.tar.gz && \
    rmdir wildfly-${WILDFLY_VERSION}

RUN curl --location --output postgresql.jar https://search.maven.org/remotecontent?filepath=org/postgresql/postgresql/${POSTGRESQL_VERSION}/postgresql-${POSTGRESQL_VERSION}.jar

ENV JBOSS_CONFIG_MAP ${JBOSS_HOME}/standalone/configuration/files/
RUN mkdir -p ${JBOSS_CONFIG_MAP} && chown wildfly:wildfly ${JBOSS_CONFIG_MAP}

COPY setup.cli ${JBOSS_HOME}/setup.cli
RUN ${JBOSS_HOME}/bin/jboss-cli.sh --file=setup.cli && \
    rm -r setup.cli ${JBOSS_HOME}/standalone/configuration/standalone_xml_history postgresql.jar

#      app  dbg  adm
EXPOSE 8080 8787 9990
# this path is also in JBOSS_HOME above
ENTRYPOINT ["/opt/jboss/wildfly/bin/standalone.sh"]
CMD ["--debug", "--read-only-server-config=standalone.xml", "-b=0.0.0.0", "-bmanagement=0.0.0.0"]
