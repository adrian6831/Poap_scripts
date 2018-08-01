#!/bin/bash
#This is a script helping initing dhcp configuration for POAP
if [ "$(whoami)" != "root" ]; then
	echo "Script must be run as root"
        exit -1
fi

if [ -e /etc/dhcp/dhcpd.conf ]; then
    echo "File /etc/dhcp/dhcpd.conf already exists. Do you want to overwrite it? y/n[n]"
    read overwrite
    if [ $overwrite == "y" ] || [ $overwrite == "Y" ] || [ $overwrite == "yes" ]; then
        bash ../DHCP_reset.sh   #Please specify relative path from prime.py or absolute path to DHCP_reset.sh here
    else
        echo "Do not overwrite /etc/dhcp/dhcpd.conf."
    fi  
else 
    echo "Cannot find /etc/dhcp/dhcpd.conf. Setting up basic configuration."
    bash ../DHCP_reset.sh       ##Please specify relative path from prime.py or absolute path to DHCP_reset.sh here
fi

service isc-dhcp-server restart
exit 0