#!/bin/bash
#This is a test script helping generating POAP configuration for a switch
if [ "$(whoami)" != "root" ]; then
	echo "Script must be run as root"
        exit -1
fi

if [ $# -ne 3 ] && [ $# -ne 1 ] && [ $# -ne 5 ] && [ $# -ne 7 ]; then
	echo --help for help
	echo "Please enter following parameters in sequence: hostname, dhcp-client-identifier/switch-identifier, router ip, [-ip fixed_ip], [-tftp tftp_server_address]."
	exit -1
fi

if [ $# -eq 1 ]; then
	if [ $1 == "--help" ]; then
		echo "Please enter following parameters in sequence: hostname, dhcp-client-identifier/switch-identifier, router ip, [-ip fixed_ip], [-tftp tftp_server_address]."
		exit 0
	else 
		echo "Invalid parameters"
		exit -1
	fi
fi

dummy_bootfile_name="poap_nexus_script.py"
dummy_tftp=true
dummy_tftp_server_address="192.168.0.3"
dynamic_ip_address=true
fixed_ip_address=0.0.0.0

hostname=$1
dhcp_client_identifier=$2
router_ip=$3
bootfile_name=$dummy_bootfile_name
tftp_server_address=$dummy_tftp_server_address

if [ $# -gt 4 ]; then
	last_var=""
	for elem in ${@:4}; do
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
		if [ "$dynamic_ip_address" == "false" ] && [ "$last_var" == "-ip" ]; then
			fixed_ip_address=$elem
		fi
		if [ "$dummy_tftp" == "false" ]  && [ "$last_var" == "-tftp" ]; then
			tftp_server_address=$elem
		fi
		last_var=$elem
	done
			
			
fi

if [ "$dynamic_ip_address" == "true" ] ; then
	output=$" 
	host $hostname { \n
	    option dhcp-client-identifier $dhcp_client_identifier, \n
	    option router $router_ip, \n
	    option host-name $hostname, \n
	    option bootfile-name $bootfile_name, \n
	    option tftp-server-address $tftp_server_address, \n}
	"
else 
	output=$" 
        host $hostname { \n
            option dhcp-client-identifier $dhcp_client_identifier, \n
	    option fixed-ip-address $fixed_ip_address, \n
            option router $router_ip, \n
            option host-name $hostname, \n
            option bootfile-name $bootfile_name, \n
            option tftp-server-address $tftp_server_address, \n}
        "
fi



if [ -e /etc/dhcp/dhcpd.conf ]; then
	if [[ "$(cat ./test_file | grep $hostname)" != "" ]]; then
		echo "Found old configuration, removing"
		idx="$(sed -n "/host $hostname {/=" ./test_file)"
		begin_idx=$idx
		while [ "$(sed "${idx}q;d" ./test_file)" != "}" ]; do
			idx=$((idx + 1))
		done 
		sed -i -e "$begin_idx, ${idx}d" ./test_file
	else 
		echo -e $output >> ./test_file 
	fi
	exit 0
else 
	echo "File /etc/dhcp/dhcpd.conf does not exist or cannot be accessed"
	exit -1
fi
