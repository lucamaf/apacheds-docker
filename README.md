# ApacheDS

This Docker image provides an [ApacheDS](https://directory.apache.org/apacheds/) LDAP server. Optionally it could be used to provide a [Kerberos server](https://directory.apache.org/apacheds/advanced-ug/2.1-config-description.html#kerberos-server) as well.

The project sources can be found on [GitHub](https://github.com/rwunsch/apacheds-docker). The Docker image on [Docker Hub](https://hub.docker.com/r/rwunsch/apacheds-docker/).


## Build

```    
	git clone https://github.com/rwunsch/apacheds-docker.git
	cd apacheds-docker
	docker build -t rwunsch/apacheds-docker . 
```
Alternatively 
```    
	git clone https://github.com/rwunsch/apacheds-docker.git
	./apacheds-docker/docker-build.sh
```

## Download Image
To download the image from the registry
```
	docker pull rwunsch/apacheds-docker
```

## Installation

The folder */var/lib/apacheds-${APACHEDS_VERSION}* contains the runtime data and thus has been defined as a volume. A [volume container](https://docs.docker.com/userguide/dockervolumes/) could be used for that. The image uses exactly the file system structure defined by the [ApacheDS documentation](https://directory.apache.org/apacheds/advanced-ug/2.2.1-debian-instance-layout.html).

The container can be started issuing the following command:
```
    docker run --name ldap --network=dockerfiles4aem_aem-network -d -p 10389:10389 rwunsch/apacheds-docker
```
Alternatively 
```    
	./apacheds-docker/docker-run.sh
```

Note: the flag "--network=dockerfiles4aem_aem-network" places the running container in the same network as the "[rwunsch/dockerfiles4aem](https://github.com/rwunsch/dockerfiles4aem)" docker containers. 

## Usage

You can manage the ldap server with the admin user *uid=admin,ou=system* and the default password *secret*. 

The *default* instance comes with a pre-configured partition *dc=adobe,dc=org*.

An indivitual admin password should be set following [this manual](https://directory.apache.org/apacheds/basic-ug/1.4.2-changing-admin-password.html).

Then you can import entries into that partition via your own *ldif* file  (see below for test-data import):
```
    ldapadd -v -h <your-docker-ip>:389 -c -x -D uid=admin,ou=system -w <your-admin-password> -f sample.ldif
```


## Customization

### Own config.ldif configuration 

It is also possible to start up your own defined Apache DS *instance* with your own configuration for *partitions* and *services*. Therefore you need to mount your [config.ldif](https://github.com/rwunsch/apacheds-docker/blob/master/instance/config.ldif) file and set the *APACHEDS_INSTANCE* environment variable properly. In the provided sample configuration the instance is named *default*. Assuming your custom instance is called *yourinstance* the following command will do the trick:
```  
    docker run --name ldap -d -p 10389:10389 -e APACHEDS_INSTANCE=yourinstance -v /path/to/your/config.ldif:/bootstrap/conf/config.ldif:ro rwunsch/apacheds-docker
```

It would be possible to use this ApacheDS image to provide a [Kerberos server](https://directory.apache.org/apacheds/advanced-ug/2.1-config-description.html#kerberos-server) as well. Just provide your own *config.ldif* file for that. Don't forget to expose the right port, then.

Also other services are possible. For further information read the [configuration documentation](https://directory.apache.org/apacheds/advanced-ug/2.1-config-description.html).


### Test-Data - 20k users and 5 groups 

I the Dockerfile you can set the environment varible "ENV TESTDATA20K" to TRUE, to have 20K Users and 5 groups imported into the LDAP server for testing. 

The default password for the test-users is "password", the password is MD5 encrypted. 

The import can take quite a while on the first start (20-30 minutes). You can check on the progress using docker:
```  
    docker logs ldap -f
```


### AEM configuration import (with rwunsch/dockerfiles4aem)

If you use this Dockerfile with AEM a default configuration is included in the folder "_opt_aem". 

If you use this Dockerfile in conjunction with "[rwunsch/dockerfiles4aem](https://github.com/rwunsch/dockerfiles4aem)" this AEM configuration can be imported directly using the "ENV INSTALL_AEM_CONFIG" set to TRUE.

This will use CURL to install the configs on "author" using "admin/admin" though the package manager.



