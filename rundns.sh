#!/bin/bash

set -x

# Install dnsmasq and SELinux packages
if sudo dnf -y install dnsmasq > /dev/null; then
  # DNF available
  sudo dnf -y install dnsmasq
  sudo dnf -y install policycoreutils policycoreutils-python selinux-policy \
      selinux-policy-targeted libselinux-utils setroubleshoot-server setools \
      setools-console mcstrans firewalld docker-engine
else
  # DNF not available, fallback to yum
  sudo yum -y install dnsmasq
  sudo yum -y install policycoreutils policycoreutils-python selinux-policy \
      selinux-policy-targeted libselinux-utils setroubleshoot-server setools \
      setools-console mcstrans firewalld bind-utils docker-engine 
fi

# install docker-compose if not present
if ! docker-compose version > /dev/null 2>&1 ; then
	curl -L https://github.com/docker/compose/releases/download/1.6.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
	chmod +x /usr/local/bin/docker-compose
fi

# Create dnsmasq config file
TMP=$(mktemp /tmp/dnsmasq.XXXXXXX)
echo 'interface=docker0' >> $TMP
echo 'domain-needed' >> $TMP
echo 'conf-dir=/etc/dnsmasq.d,.rpmnew,.rpmsave,.rpmorig' >> $TMP
sudo cp $TMP /etc/dnsmasq.conf
rm $TMP

# start dnsmasq with new configuration
sudo systemctl enable dnsmasq.service && sudo systemctl restart dnsmasq.service

# Start firewalld if not running
sudo systemctl enable firewalld.service && sudo systemctl restart firewalld.service

# Open firewall of host from containers for DNS query
sudo firewall-cmd --zone=$(firewall-cmd --get-active-zones | grep -v grep | grep -v interfaces) --remove-port=53/tcp --permanent
sudo firewall-cmd --zone=$(firewall-cmd --get-active-zones | grep -v grep | grep -v interfaces) --remove-port=53/udp --permanent
sudo firewall-cmd --reload

# copy dnsmasq periodic update scripts and run as service
sudo cp update-dnsmasq.sh /usr/local/bin/update-dnsmasq.sh
sudo cp update-dnsmasq.service /usr/lib/systemd/system/update-dnsmasq.service

sudo systemctl enable update-dnsmasq && sudo systemctl start update-dnsmasq
