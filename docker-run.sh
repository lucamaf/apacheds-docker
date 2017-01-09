docker run --name ldap --network=dockerfiles4aem_aem-network -d -p 10389:10389 rwunsch/apacheds-docker
docker logs ldap -f
