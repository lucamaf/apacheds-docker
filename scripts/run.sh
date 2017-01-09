#!/bin/bash

# Environment variables:
# APACHEDS_VERSION
# APACHEDS_INSTANCE
# APACHEDS_BOOTSTRAP
# APACHEDS_DATA
# APACHEDS_USER
# APACHEDS_GROUP

APACHEDS_INSTANCE_DIRECTORY=${APACHEDS_DATA}/${APACHEDS_INSTANCE}

## When a fresh data folder is detected then bootstrap the instance configuration.
if [ ! -d ${APACHEDS_INSTANCE_DIRECTORY} ]; then
    mkdir ${APACHEDS_INSTANCE_DIRECTORY}
    cp -rv ${APACHEDS_BOOTSTRAP}/* ${APACHEDS_INSTANCE_DIRECTORY}
    chown -v -R ${APACHEDS_USER}:${APACHEDS_GROUP} ${APACHEDS_INSTANCE_DIRECTORY}
	
	## If TESTDATA20K is set to TRUE the test-dataset with 20K users will be installed on first startup
	if [ "$TESTDATA20K" = "TRUE" ]; then
		/opt/apacheds-${APACHEDS_VERSION}/bin/apacheds console ${APACHEDS_INSTANCE} &
		sleep 15
		ldapadd -v -h localhost:10389 -c -x -D uid=admin,ou=system -w secret -f /bootstrap/startup-entry.ldif
		/opt/apacheds-${APACHEDS_VERSION}/bin/apacheds stop ${APACHEDS_INSTANCE}
	fi
	
	if [ "$INSTALL_AEM_CONFIG" = "TRUE" ]; then
		 curl -u admin:admin -F file=@"${APACHEDS_BOOTSTRAP}/optional/ldap-config-server-test-1.0.0.zip" -F name="ldap-config-server-test" -F force=true -F install=true http://author:4502/crx/packmgr/service.jsp
	fi 
fi

# Execute the server in console mode and not as a daemon.
/opt/apacheds-${APACHEDS_VERSION}/bin/apacheds console ${APACHEDS_INSTANCE}
