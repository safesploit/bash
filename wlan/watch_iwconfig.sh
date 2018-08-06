#iwconfig requires root for "Bit rate"
#
if [ `whoami` != 'root' ]
  then
    echo "MUST be ROOT!"
    exit
fi
#
ifconfig -a | sed 's/[ \t].*//;/^\(lo:\|\)$/d'
read -p "Enter interface: " int
watch -n1 iwconfig $int
