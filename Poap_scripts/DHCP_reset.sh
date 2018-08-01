#!/bin/bash
#This script reset dhcpd.conf to default POAP setting

if [ "$(whoami)" != "root" ]; then
	echo "Script must be run as root"
    exit -1
fi

cat << EOF > /etc/dhcp/dhcpd.conf
    ddns-update-style none;

    option domain-name "example.org";
    option domain-name-servers ns1.example.org, ns2.example.org;

    default-lease-time 3600;
    max-lease-time 7200;

    log-facility local7;

    option tftp-server-address code 150 = ip-address;
EOF

service isc-dhcp-server restart
exit 0