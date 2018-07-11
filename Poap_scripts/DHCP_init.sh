#!/bin/bash
#This is a script helping initing dhcp configuration for POAP

if [ "$(whoami)" != "root" ]; then
	echo "Script must be run as root"
        exit -1
fi

if [ -e /etc/dhcp/dhcpd.conf ]; then
    
        
    
else 
    echo "Cannot find /etc/dhcp/dhcpd.conf. Setting up basic configuration."
    bash ./DHCP_setup_basic.sh
fi

service isc-dhcp-server restart


