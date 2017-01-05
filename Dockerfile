FROM ubuntu:14.04
MAINTAINER Robert Wunsch <wunsch@gmx.de>

#############################################
# ApacheDS installation
#############################################

ENV APACHEDS_VERSION 2.0.0-M23
ENV APACHEDS_ARCH amd64
ENV APACHEDS_ARCHIVE apacheds-${APACHEDS_VERSION}-${APACHEDS_ARCH}.deb

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections \
    && apt-get update \
    && apt-get install -y ldap-utils procps openjdk-7-jre-headless curl \
    && curl http://www.eu.apache.org/dist//directory/apacheds/dist/${APACHEDS_VERSION}/${APACHEDS_ARCHIVE} > ${APACHEDS_ARCHIVE} \
    && dpkg -i ${APACHEDS_ARCHIVE} \
    && rm ${APACHEDS_ARCHIVE}


#############################################
# ApacheDS bootstrap configuration
#############################################

ENV APACHEDS_INSTANCE default
ENV APACHEDS_BOOTSTRAP /bootstrap
ENV APACHEDS_SCRIPT run.sh
ENV APACHEDS_CMD /${APACHEDS_SCRIPT}

ENV APACHEDS_USER apacheds
ENV APACHEDS_GROUP apacheds

ADD scripts/${APACHEDS_SCRIPT} ${APACHEDS_CMD}

RUN chown ${APACHEDS_USER}:${APACHEDS_GROUP} ${APACHEDS_CMD} \
    && chmod u+rx ${APACHEDS_CMD}

ADD instance/* ${APACHEDS_BOOTSTRAP}/conf/
ADD startup-entry.ldif ${APACHEDS_BOOTSTRAP}/

RUN mkdir ${APACHEDS_BOOTSTRAP}/cache \
    && mkdir ${APACHEDS_BOOTSTRAP}/run \
    && mkdir ${APACHEDS_BOOTSTRAP}/log \
    && mkdir ${APACHEDS_BOOTSTRAP}/partitions \
    && chown -R ${APACHEDS_USER}:${APACHEDS_GROUP} ${APACHEDS_BOOTSTRAP}

#############################################
# Docker configuration
#############################################

ENV APACHEDS_DATA /var/lib/apacheds-${APACHEDS_VERSION}
	
# Ports defined by the default instance configuration:
# 10389: ldap
# 10636: ldaps
# 60088: kerberos
# 60464: changePasswordServer
# 8080: http
# 8443: https
EXPOSE 10389 10636 60088 60464 8080 8443

VOLUME ${APACHEDS_DATA}
VOLUME ${APACHEDS_DATA}\${APACHEDS_INSTANCE}\log	
	
#############################################
# ApacheDS wrapper command
#############################################

CMD ${APACHEDS_CMD}
