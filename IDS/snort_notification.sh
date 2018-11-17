#!/bin/bash
#This script is responsible for ensuring NotifyOSD supplies Snort notifications
snort.log = /var/log/snort/snort.log
tail -f "$snort.log" | xargs -d '\n' -L1 notify-send --


#Refer to V
# https://askubuntu.com/questions/1067005/display-notifyosd-notification-from-a-log-file/
