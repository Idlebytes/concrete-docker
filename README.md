# concrete-docker

This repository hosts content for running concrete5 CMS with MariaDB on docker. Docker compose is used to manage the containers

#Build docker images from docker file using compose
$ docker-compose build

# Start our application. This runs the CMD specified in the Dockerfiles
$ docker-compose up

# If there is any changes made, we can just restart the web service to update from github
$ docker-compose restart web
