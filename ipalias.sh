#!/bin/bash
#IP Alias enabler
#Written By Manjot Singh
#Version: 1.1
#Last Updated: 2012-04-04

NETSCRIPT="/etc/sysconfig/network-scripts"

echo

#check for correct command
if [[ -z "$1" || -z "$2" ]] || [[ "$2" != "up"  && "$2" != "down" ]]; then
	echo "Usage: ipalias interface up|down [--restart]"
	echo "e.g. ipalias eth0:0 up"
	echo
	exit
fi

#check if it is an alias
if [[ "$1" != "eth"*":"* ]]; then
	echo "Not a valid ip alias interface name, format should be like eth0:0"
	exit
fi

#check if the file exists
if [[ ! -e "$NETSCRIPT/ifcfg-$1" ]] && [[ ! -e "$NETSCRIPT/ifcfg-$1.bak" ]]
then
	echo "Interface $1 does not exist. Please check that $NETSCRIPT/ifcfg-$1 or $NETSCRIPT/ifcfg-$1.bak has been created."
	exit
fi

source $NETSCRIPT/ifcfg-$1*

if [[ "$2" == "up" ]]; then
	if [[ -e "$NETSCRIPT/ifcfg-$1.bak" ]]; then
		echo "Moving ifcfg-$1.bak to ifcfg-$1"
		mv "$NETSCRIPT/ifcfg-$1.bak" "$NETSCRIPT/ifcfg-$1"
	fi
else
        if [[ -e "$NETSCRIPT/ifcfg-$1" ]]; then
                echo "Moving ifcfg-$1 to ifcfg-$1.bak"
                mv "$NETSCRIPT/ifcfg-$1" "$NETSCRIPT/ifcfg-$1.bak"
        fi
fi

if [[ -n "$3" && "$3" == "-"*"restart" ]]; then
	echo "Restarting Network..."
	/etc/init.d/network restart
	echo
else
	echo "Bringing $2 interface $1..."
	ifconfig $1 $IPADDR netmask $NETMASK $2
fi


if [[ "$2" == "up" ]]; then
	echo "Letting others on the network know the alias is now here..."
	arping -c 4 -A -I eth0 $IPADDR > /dev/null
fi

echo
echo "Done!"
echo

