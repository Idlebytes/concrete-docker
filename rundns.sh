#!/bin/bash

set -x

# Install dnsmasq and SELinux packages
if sudo dnf -y install dnsmasq > /dev/null; then
  # DNF available
  sudo dnf -y install dnsmasq
  sudo dnf -y install policycoreutils policycoreutils-python selinux-policy \
      selinux-policy-targeted libselinux-utils setroubleshoot-server setools \
      setools-console mcstrans firewalld
else
  # DNF not available, fallback to yum
  sudo yum -y install dnsmasq
  sudo yum -y install policycoreutils policycoreutils-python selinux-policy \
      selinux-policy-targeted libselinux-utils setroubleshoot-server setools \
      setools-console mcstrans firewalld bind-utils docker-engine docker-compose
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
