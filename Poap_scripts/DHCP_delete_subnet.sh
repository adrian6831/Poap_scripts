#!/bin/bash
#This script help remove a subnet block from dhcpd.conf

if [ "$(whoami)" != "root" ]; then
    echo "This script must be executed as root"
    exit -1
fi

if [ $# -ne 2 ]; then 
    echo "Invalid number of parameters $#. This script only take 2 parameters: network_addr and network_mask"
    exit -1
fi


network_addr=$1
netmask=$2

if [ -e /etc/dhcp/dhcpd.conf ]; then
    if [[ "$(cat /etc/dhcp/dhcpd.conf | grep "subnet $network_addr")" != "" ]]; then
        echo "Found old configuration, removing"
        idx="$(sed -n "/subnet $network_addr netmask $netmask {/=" /etc/dhcp/dhcpd.conf)"
        begin_idx=$((idx - 1))
        while [ "$(sed "${idx}q;d" /etc/dhcp/dhcpd.conf)" != "}" ]; do
            idx=$((idx + 1))
        done 
        idx=$((idx + 1))
        sed -i -e "$begin_idx, ${idx}d" /etc/dhcp/dhcpd.conf
        echo "Done"
    else
        echo "Not found what to delete"
    fi
else
	echo "File /etc/dhcp/dhcpd.conf does not exist or cannot be accessed"
	exit -1
fi

exit 0