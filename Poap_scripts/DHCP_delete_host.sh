#!/bin/bash
#This script help remove a host block from dhcpd.conf

if [ "$(whoami)" != "root" ]; then
    echo "This script must be executed as root"
    exit -1
fi

if [ $# -ne 1 ]; then 
    echo "Invalid number of parameters $#. This script only take 1 parameter: hostname"
    exit -1
fi

hostname=$1

if [ -e /etc/dhcp/dhcpd.conf ]; then
    if [[ "$(cat /etc/dhcp/dhcpd.conf | grep "host $hostname {")" != "" ]]; then
        echo "Found old configuration, removing"
        idx="$(sed -n "/host $hostname {/=" /etc/dhcp/dhcpd.conf)"
        begin_idx=$((idx - 1))
        while [ "$(sed "${idx}q;d" /etc/dhcp/dhcpd.conf)" != "}" ]; do
            idx=$((idx + 1))
        done 
        idx=$((idx + 1))
        sed -i -e "$begin_idx, ${idx}d" /etc/dhcp/dhcpd.conf
        echo "Done"
    else 
        echo -e $output >> /etc/dhcp/dhcpd.conf 
    fi
else
	echo "File /etc/dhcp/dhcpd.conf does not exist or cannot be accessed"
	exit -1
fi

exit 0