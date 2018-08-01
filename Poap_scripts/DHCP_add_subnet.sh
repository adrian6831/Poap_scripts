#!/bin/bash
#This is a script allowing adding a subnet on 
#/etc/dhcp/dhcpd.conf to configure multiple switches 
#simutaneously or to prepare a subnet for adding host through
#DHCP_add_host.sh  

check_repeated_params () {
    if [ "$1" == "false" ]; then
            echo "Repeated parameters"
            exit -1
    fi
}

if [ "$(whoami)" != "root" ]; then
    echo "This script must be executed as root"
    exit -1
fi

if [[ $# -ne 1  && ( $# -lt 5  ||  $# -gt 12 ) ]]; then 
    echo "Invalid number of parameters $#, please use --help for help."
    exit -1
fi

if [ $# -eq 1 ]; then
    if [ "$1" == "--help" ]; then
        #--mass along will setup a default subnet for POAP mass configuration; 
        #if you change any of router_addr, tftp_server_addr, 
        #or bootfile, you may not specify it.
        echo -e "Please enter network_address, netmask, range_start, range_end, broadcast_address, [-r router_address], [-tftp tftp_server_address], [-boot bootfile] [--mass] in sequence"
        exit 0
    else
        echo "Invalid parameter"
        exit -1
    fi
fi

dummy_router_addr=true
dummy_tftp=true
dummy_bootfile=true

network_addr=$1
netmask=$2
range_start=$3
range_end=$4
broadcast_addr=$5
router_addr="172.16.0.1"
tftp_addr="172.16.0.2"
bootfile="poap_nexus_script.py"

output=$"\n
subnet $network_addr netmask $netmask {\n
    range $range_start $range_end;\n    
    option broadcast-address $broadcast_addr;\n    
    default-lease-time 3600;\n    
    max-lease-time 7200;\}\n
"
if [ $# -gt 5 ]; then
    last_elem=""
    for elem in ${@:6}; do 
        if [ "$elem" == "-r" ]; then 
            check_repeated_params "$dummy_router_addr"
            dummy_router_addr=false 
        fi 
        if [ "$elem" == "-tftp" ]; then 
            check_repeated_params "$dummy_tftp"
            dummy_tftp=false 
        fi 
        if [ "$elem" == "-boot" ]; then
            check_repeated_params "$dummy_bootfile"
            dummy_bootfile=false 
        fi 
        if [ "$last_elem" == "-r" ]; then 
            router_addr=$elem
        fi 
        if [ "$last_elem" == "-tftp" ]; then 
            tftp_addr=$elem 
        fi 
        if [ "$last_elem" == "-boot" ]; then 
            bootfile=$elem 
        fi
        last_elem=$elem 
    done
    output=$"\n
    subnet $network_addr netmask $netmask {\n 
        range $range_start $range_end;\n    
        option broadcast-address $broadcast_addr;\n    
        default-lease-time 3600;\n    
        max-lease-time 7200;\n    
        option bootfile_name \"$bootfile\";\n    
        option routers $router_addr;\n    
        option tftp-server-address $tftp_addr;\n}\n
    " 
fi 

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
		echo -e $output >> /etc/dhcp/dhcpd.conf
        echo "Done"
	else 
		echo -e $output >> /etc/dhcp/dhcpd.conf 
	fi
else
	echo "File /etc/dhcp/dhcpd.conf does not exist or cannot be accessed"
	exit -1
fi

service isc-dhcp-server restart
/etc/init.d/networking restart

exit 0