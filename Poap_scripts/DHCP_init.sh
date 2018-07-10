#!/bin/bash
#This is a script helping initing dhcp configuration for POAP

if [ "$(whoami)" != "root" ]; then
	echo "Script must be run as root"
        exit -1
fi

if [ -e /etc/dhcp/dhcpd.conf ]; then
    
else 
    cat << EOF > /etc/dhcp/dhcpd.conf
    ddns-update-style none;

    option domain-name "example.org";
    option domain-name-servers ns1.example.org, ns2.example.org;

    default-lease-time 3600;
    max-lease-time 7200;

    log-facility local7;

    option tftp-server-address code 150 = ip-address;

    subnet 172.16.0.0 netmask 255.255.0.0 {
        range 172.16.1.0 172.16.255.253;
        option broadcast-address 172.16.255.255;
        default-lease-time 3600;
        max-lease-time 7200;
    }
EOF
#172.16.0.10 - 172.16.0.255 are reserved for manually setup hosts
fi

service isc-dhcp-server restart


