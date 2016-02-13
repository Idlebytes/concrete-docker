===============
concrete-docker
===============


This repository hosts content for running concrete5 CMS with MariaDB on docker. Docker compose is used to manage the containers


Steps to setup the docker host (The instructions is for Fedora 23, RHEL7 and CentOS 7, but you will be easily able to find equivalent commands for Debian)

1. Install git, docker and docker compose packages and start docker process, enable docker service at system boot and run docker as non-root user($USER)

$ sudo yum install docker
$ sudo systemctl start docker
$ sudo systemctl enable docker
$ sudo usermod -a -G docker $USER

2. Clone the repository

$ git clone git@github.com:Idlebytes/concrete-docker.git

3. Build docker images from docker file using compose

$ docker-compose build

4. Start our application. This runs the CMD specified in the Dockerfiles

$ docker-compose up


If there is any changes made only to individual container, we can just restart the particular service to update from github

$ docker-compose restart {web|data|db}


Now, the base Infra will be ready and we can start CMS installation


=========================
Installation of Concrete5
=========================

1. The above instructions will create a fresh installation of MariaDB and will have concrete binaries and necessary libraries hosted on apache. We can start the concrete installation now

2. Access the URL using http://{hostname}:8080/concrete/ if using public endpoint. Otherwise use http://{docker-web-ip}/concrete/ and see the installation home page of concrete.

3. Select language, and provide necessary details like CMS admin password, and the DB details. Since MariaDB is running on non standard port, the details are below:

DB hostname : {docker-db-ip};port=3305
DB username : concrete
DB password : concrete
DB name     : cms

4. Click next with these details, and the CMS is ready now to create new content

Note: docker-web-ip and docker-db-ip are ip address of individual container. This assumes that we host both containers in same VM and is reachable using container's private IP address


==========================
Installation of DNS server
==========================

The implementation initially uses container's dynamic IP address to connect to MariaDB. Since the IP changes everytime when we restart the container, we need to have some mechanism of addressing the container, using the name. We achieve this by setting up local DNS server on the docker host using Dnsmasq.

Steps to setup dnsmasq

1. Run script ./rundns.sh which installs and configures necessary DNS settings mentioned in below points a) to d). No need to run those again, provided below just for informative purposes

----------------------------------------------------------------------------------------------------------------------------
a) Install Dnsmasq on docker host

$ sudo yum install dnsmasq

b) Configure dnsmasq settings (add below config in /etc/dnsmasq.conf)

interface=docker0
domain-needed

c) Start dnsmasq (restart dnsmasq if already running, or kill the running process on port 53 if something already running)

$ sudo systemctl enable dnsmasq
$ sudo systemctl start dnsmasq

d) Enable firewall for DNS in host machine

$ sudo firewall-cmd --zone=$(firewall-cmd --get-active-zones | grep -v grep | grep -v interfaces) --remove-port=53/tcp --permanent
$ sudo firewall-cmd --zone=$(firewall-cmd --get-active-zones | grep -v grep | grep -v interfaces) --remove-port=53/udp --permanent
$ sudo firewall-cmd --reload


----------------------------------------------------------------------------------------------------------------------------

Note: Test whether containers are able to resolve DNS using dnsmasq

$ docker run -t -i --rm debian /bin/bash
$ apt-get update && apt-get install -y --no-install-recommends dnsutils
$ dig @<docker0 IP> github.com


==============
Enable SELinux
==============

SELinux enforces mandatory access controls and is highly recommended (NOT MANDATORY) to run on Fedora, CentOS and RHEL based systems

1. Check SELinux is in Enforcing mode - desired starte

2. If Selinux is in disabled state, change it to permissive and look for any SELinux warnings during boot. First fix them before changing to Enforcing, else machine won't start during next reboot

3. If there is no SELinux errors in permissive mode, change to enforcing mode and reboot the system

=========================
set DNS server for docker
=========================

We need to force docker to use dnsmasq as dns server for containers

1. Stop the running service

$ sudo systemctl stop docker.service

2. Edit the service file /usr/lib/systemd/system/docker.service and add "--dns 172.17.42.1" to docker start up arguments

$ sudo vi /usr/lib/systemd/system/docker.service

  ExecStart=/usr/bin/docker daemon --dns 172.17.42.1

3. Reload the configuration and start docker service

$ sudo systemctl daemon-reload
$ sudo systemctl start docker.service
