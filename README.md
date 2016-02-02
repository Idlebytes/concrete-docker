# concrete-docker

This repository hosts content for running concrete5 CMS with MariaDB on docker. Docker compose is used to manage the containers

#Build docker images from docker file using compose
$ docker-compose build

# Start our application. This runs the CMD specified in the Dockerfiles
$ docker-compose up

# If there is any changes made, we can just restart the web service to update from github
$ docker-compose restart web


# Installation of Concrete5

1. The above instructions will create a fresh installation of MariaDB and will have concrete binaries and necessary libraries hosted on apache. We can start the concrete installation now

2. Access the URL using http://{hostname}:8080/concrete/ if using public endpoint. Otherwise use http://{docker-web-ip}/concrete/ and see the installation home page of concrete.

3. Select language, and provide necessary details like CMS admin password, and the DB details. Since MariaDB is running on non standard port, the details are below:
    DB hostname : {docker-db-ip};port=3305
    DB username : concrete
    DB password : concrete
    DB name     : cms

4. Click next with these details, and the CMS is ready now to create new content

Note: docker-web-ip and docker-db-ip are ip address of individual container. This assumes that we host both containers in same VM and is reachable using container's private IP address
