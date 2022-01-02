ARG JDK_VERSION
FROM openjdk:${JDK_VERSION}
ARG WILDFLY_VERSION=25.0.1.Final
LABEL maintainer=https://github.com/t1 license=Apache-2.0 name='' build-date='' vendor=''

# this path is also in ENTRYPOINT below
ENV JBOSS_HOME /opt/jboss/wildfly

# Ensure signals are forwarded to the JVM process correctly for graceful shutdown
ENV LAUNCH_JBOSS_IN_BACKGROUND true

#      app  dbg  adm
EXPOSE 8080 8787 9990

USER root
RUN addgroup --system --gid 1000 wildfly \
    && adduser --system --home $JBOSS_HOME --uid 1000 -gid 1000 wildfly

USER wildfly
WORKDIR $JBOSS_HOME
RUN curl -L -O https://github.com/wildfly/wildfly/releases/download/${WILDFLY_VERSION}/wildfly-${WILDFLY_VERSION}.tar.gz && \
    tar xf wildfly-${WILDFLY_VERSION}.tar.gz && \
    mv wildfly-${WILDFLY_VERSION}/* . && \
    mv wildfly-${WILDFLY_VERSION}/.* . && \
    rm wildfly-${WILDFLY_VERSION}.tar.gz

# this path is also in JBOSS_HOME above
ENTRYPOINT ["/opt/jboss/wildfly/bin/standalone.sh"]
CMD ["--debug", "--read-only-server-config=standalone.xml", "-b=0.0.0.0", "-bmanagement=0.0.0.0"]
