#!/bin/bash
#Configures the interface to prior state before monitor_mode.sh
#
if [ `whoami` != 'root' ]
then
  echo "MUST be ROOT!"
  exit
else
  ifconfig -a | sed 's/[ \t].*//;/^\(lo:\|\)$/d'
  read -p "Enter interface: " int
  mac=$(macchanger $int | grep 'Permanent MAC:' |  grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}')
  ifconfig $int down
  iwconfig $int mode manage
  macchanger $int $mac
  ifconfig $int up
  #
  echo "$int in stock configuration with MAC: $mac"
  echo "Connect to a Wi-Fi network and run 'ping 1.1.1.1'"
  sleep 2 && cinnamon-settings network &
fi
