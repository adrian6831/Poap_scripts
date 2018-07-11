cat << EOF > /etc/dhcp/dhcpd.conf
    ddns-update-style none;

    option domain-name "example.org";
    option domain-name-servers ns1.example.org, ns2.example.org;

    default-lease-time 3600;
    max-lease-time 7200;

    log-facility local7;

    option tftp-server-address code 150 = ip-address;
EOF