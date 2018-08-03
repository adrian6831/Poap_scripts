#!/bin/bash
#This is a script helping initing dhcp configuration for POAP
if [ "$(whoami)" != "root" ]; then
	echo "Script must be run as root"
        exit -1
fi

if [ -e /etc/dhcp/dhcpd.conf ]; then
    echo "File /etc/dhcp/dhcpd.conf already exists. Do you want to overwrite it? y/n[n]"
    read overwrite
    if [ "$overwrite" == "y" ] || [ "$overwrite" == "Y" ] || [ "$overwrite" == "yes" ]; then
        cat << EOF > /etc/dhcp/dhcpd.conf
        ddns-update-style none;

        option domain-name "example.org";
        option domain-name-servers ns1.example.org, ns2.example.org;

        default-lease-time 3600;
        max-lease-time 7200;

        log-facility local7;

        option tftp-server-address code 150 = ip-address;
EOF
    else
        echo "Do not overwrite /etc/dhcp/dhcpd.conf."
    fi  
else 
    echo "Cannot find /etc/dhcp/dhcpd.conf. Setting up basic configuration."
    cat << EOF > /etc/dhcp/dhcpd.conf
    ddns-update-style none;

    option domain-name "example.org";
    option domain-name-servers ns1.example.org, ns2.example.org;

    default-lease-time 3600;
    max-lease-time 7200;

    log-facility local7;

    option tftp-server-address code 150 = ip-address;
EOF
fi

service isc-dhcp-server restart
exit 0