#!/bin/bash
#
if [ `whoami` != 'root' ]
  then
    echo "MUST be ROOT!"
    exit
fi
#
ifconfig -a | sed 's/[ \t].*//;/^\(lo:\|\)$/d'
read -p "Enter interface: " int
read -p "Enter desired MAC address(random = -r): " mac
echo "$int having MAC address spoofed and placed in monitor mode!"
ifconfig $int down
iwconfig $int mode monitor
macchanger $int $mac
ifconfig $int up
