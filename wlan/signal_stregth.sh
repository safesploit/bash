if [ `whoami` != 'root' ]
  then
    echo "MUST be ROOT!"
    exit
fi
#
watch -n1 "awk 'NR==3 {print \"WiFi Signal Strength = \" \$3 \"00 %\"}''' /proc/net/wireless"
