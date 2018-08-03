#!/bin/bash
# This script help modify poap script to config different routers
# This script doesn't have any false-proof mechanism. Don't use it along
# unless you know what you are doing.
if [ $# -ne 11 ]; then
    echo "Invalid number of parameters $#"
    exit -1
fi

script=$1

# Input parameters corresponds to members of array key whose indexs are
# the same as theirs in array content.

key=("\"username\": " "\"password\": " "\"hostname\": " "\"transfer_protocol\": "
    "\"mode\": " "\"source_config_file\": " "\"config_path\": " "\"target_image_path\": "
    "\"target_system_image\": " "\"user_app_path\": " "\"enable_upgrade\": "
    "\"skip_single_image_check\": ")
content=("\"${2}\"," "\"${3}\"," "\"${4}\"," "\"ftp\"," "\"raw\"," "\"${5}\"," "\"${6}\"," 
    "\"${7}\"," "\"${8}\"," "\"${9}\"," "\"${10}\"," "\"${11}\"," )

script_idx="$(sed -n "/options = {/=" $script)"
i=0

script_idx=$((script_idx + 1))
while [ "$(sed "${script_idx}q;d" ${script})" != "}" ]; do
    sed -i "${script_idx}s;.*;    ${key[i]}${content[i]};" $script
    script_idx=$((script_idx + 1))
    i=$((i + 1))
done 

#"poap.py" is the file name of poap nexus script; change it if you renamed it
f=$script ; cat $f | sed '/^#md5sum/d' > $f.md5 ; sed -i \
"s/^#md5sum=.*/#md5sum=\"$(md5sum $f.md5 | sed 's/ .*//')\"/" $f

exit 0