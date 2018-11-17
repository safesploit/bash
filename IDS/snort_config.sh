#Below are six different NMap port scans for Snort.
# Identify NMAP Ping Scan (IMCP)
#nmap -sP 192.168.1.105 --disable-arp-ping
sudo echo "alert icmp any any -> 192.168.1.105 any (msg: "NMAP ping sweep Scan"; dsize:0;sid:10000004; rev: 1; )" > /etc/snort/rules/local.rules

# Identify NMAP TCP Scan
#nmap -sT -p22 192.168.1.105
sudo echo "alert tcp any any -> 192.168.1.105 22 (msg: "NMAP TCP Scan";sid:10000005; rev:2; )" > /etc/snort/rules/local.rules

# Identify NMAP XMAS Scan
#nmap -sX -p22 192.168.1.105
sudo echo "alert tcp any any -> 192.168.1.105 22 (msg:"Nmap XMAS Tree Scan"; flags:FPU; sid:1000006; rev:1; )" > /etc/snort/rules/local.rules

# Identify NMAP FIN Scan
#nmap -sF -p22 192.168.1.105
sudo echo "alert tcp any any -> 192.168.1.105 22 (msg:"Nmap FIN Scan"; flags:F; sid:1000008; rev:1;)" > /etc/snort/rules/local.rules

# Identify NMAP NULL Scan
#nmap -sN -p22 192.168.1.105
sudo echo "alert tcp any any -> 192.168.1.105 22 (msg:"Nmap NULL Scan"; flags:0; sid:1000009; rev:1; )" > /etc/snort/rules/local.rules

# Identify NMAP UDP Scan
#nmap -sU -p68 192.168.1.105
sudo echo "alert udp any any -> 192.168.1.105 any ( msg:"Nmap UDP Scan"; sid:1000010; rev:1; )" > /etc/snort/rules/local.rules

#ifconfig -a | sed 's/[ \t].*//;/^\(lo:\|\)$/d'
#read -p "Enter interface: " int
#sudo snort -A console -q -u snort -g snort -c /etc/snort/snort.conf -i $int
