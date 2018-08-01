#!/bin/bash
#This is a script helping generating POAP configuration for a switch

if [ "$(whoami)" != "root" ]; then
	echo "Script must be run as root"
        exit -1
fi

if [ $# -ne 2 ] && [ $# -ne 1 ] && [ $# -ne 4 ] && [ $# -ne 6 ] && [ $# -ne 8 ] && [ $# -ne 10 ]; then
	echo --help for help
	echo "Please enter following parameters in sequence: hostname, dhcp-client-identifier/switch-identifier, [-r router_ip], [-ip fixed_ip], [-tftp tftp_server_address], [-boot bootfile]."
	exit -1
fi

if [ $# -eq 1 ]; then
	if [ $1 == "--help" ]; then
		echo "Please enter following parameters in sequence: hostname, dhcp-client-identifier/switch-identifier, [-r router_ip], [-ip fixed_ip], [-tftp tftp_server_address], [-boot bootfile]."
		exit 0
	else 
		echo "Invalid parameters"
		exit -1
	fi
fi

#By default, this host is in subnet 172.16.0.0, with 172.16.0.1 
#as router.
dummy_bootfile=true
dummy_tftp=true
dummy_router=true
dynamic_ip_address=true
fixed_ip_address=0.0.0.0

hostname=$1
dhcp_client_identifier=$2
router_ip="172.16.0.1"
bootfile_name="poap_nexus_script.py"
tftp_server_address="172.16.0.2"

if [ $# -gt 3 ]; then
	last_var=""
	for elem in ${@:3}; do
		if [ "$elem" == "-ip" ]; then
			if [ "$dynamic_ip_address" == "true" ]; then
				dynamic_ip_address=false
			else
				echo "Repeated parameters"
				exit -1
			fi
		fi
		if [ "$elem" == "-tftp" ]; then
			if [ "$dummy_tftp" == "true" ]; then
				dummy_tftp=false
			else 
				echo "Repeated parameters"
				exit -1
			fi
		fi
		if [ "$elem" == "-boot" ]; then
			if [ "$dummy_bootfile" == "true" ]; then
				dummy_bootfile=false
			else
				echo "Repeated parameters"
				exit -1
			fi
		fi
		if [ "$elem" == "-r" ]; then
			if [ "$dummy_router" == "true" ]; then
				dummy_router=false 
			else 
				echo "Repeated parameters"
				exit -1
			fi 
		fi
		if [ "$dynamic_ip_address" == "false" ] && [ "$last_var" == "-ip" ]; then
			fixed_ip_address=$elem
		fi
		if [ "$dummy_tftp" == "false" ]  && [ "$last_var" == "-tftp" ]; then
			tftp_server_address=$elem
		fi
		if [ "$dummy_bootfile" == "false" ] && [ "$last_var" == "-boot" ]; then
			bootfile_name=$elem
		fi
		if [ "$dummy_router" == "false" ] && [ "$last_var" == "-r" ]; then
			router_ip=$elem 
		fi 
		last_var=$elem
	done		
fi

if [ "$dynamic_ip_address" == "true" ] ; then
	output=$"\n
	host $hostname { \n
		option dhcp-client-identifier \"$dhcp_client_identifier\"; \n
		option router $router_ip; \n
		option host-name \"$hostname\"; \n
		option bootfile-name \"$bootfile_name\"; \n
		option tftp-server-address $tftp_server_address; \n}\n
	"
else 
	output=$"\n
	host $hostname { \n
		option dhcp-client-identifier \"$dhcp_client_identifier\"; \n
		option fixed-ip-address $fixed_ip_address; \n
		option router $router_ip; \n
		option host-name \"$hostname\"; \n
		option bootfile-name \"$bootfile_name\"; \n
		option tftp-server-address $tftp_server_address; \n}\n
	"
fi

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