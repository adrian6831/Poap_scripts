script=$1
username="inspur"


idx="$(sed -n "/options = {/=" $script)"

while [ "$(sed "${idx}q;d" /etc/dhcp/dhcpd.conf)" != "}" ]; do
    idx=$((idx + 1))
done 

#"poap.py" is the file name of poap nexus script; change it if you renamed it
f=poap.py ; cat $f | sed '/^#md5sum/d' > $f.md5 ; sed -i \
"s/^#md5sum=.*/#md5sum=\"$(md5sum $f.md5 | sed 's/ .*//')\"/" $f