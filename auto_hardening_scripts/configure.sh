#!/bin/bash
# Author: *safesploit
# Version: *Beta 1
if [ "$(whoami)" != "root" ]
then
  echo "MUST be ROOT!"
  exit
else
  echo "Now load OpSec hardening configuration scripts..."
  echo "###################################################"
  PS3='Please enter your choice: '
  options=(
          "Auto Install" \
          "OpenSSH Server Host Keys" \
          "OpenSSH Server Config" \
          "SSH Port Knocking" \
          "Apache SSL Mods" \
          "Apache Let's Encrypt" \
          "Tor Hidden Service" \
          "Fail2Ban - SSH" \
          "Snort - NotifyOSD" \
          "Install patched NotifyOSD" \
          "Secure Shared Memory" \
          "Unattended Upgrades - APT" \
          "Secure GRUB Boot Loader" \
          "Check for empty password accounts" \
          "Check if UID Set To 0" \
          "View Open Ports" \
          "Harden Networking Layer" \
          "Prevent IP Spoofing" \
          "Quit"
          ) # Upon final version rearrange options into alphabetical order.
  pushd $(dirname "${0}") > /dev/null
select opt in "${options[@]}"
do
  case $opt in
    "OpenSSH Server Host Keys") #To be verified
        ed25519_key="/etc/ssh/ssh_host_ed25519_key"
        rsa_key="/etc/ssh/ssh_host_rsa_key"
        comment = "Auto hardening scripts by safesploit"
        sudo ssh-keygen -a 1000 -b 521 -C "${comment}" -f ${ed25519_key} -o -t ed25519
        sudo ssh-keygen -a 1000 -b 4096 -C "${comment}" -f ${rsa_key} -o -t rsa
        #Change ownership and access permissions
        #Test ssh-keygen permissions, the steps below may be redundant!
        sudo chown root:root ${ed25519}*
        sudo chown root:root ${rsa_key}*
        sudo chmod 600 ${ed25519}                         #Private key
        sudo chmod 644 /etc/ssh/ssh_host_ed25519_key.pub  #Public key
        sudo chmod 600 ${rsa_key}                         #Private key
        sudo chmod 644 /etc/ssh/ssh_host_rsa_key.pub      #Public key
        sudo service ssh stop
        #sudo echo "HostKey /etc/ssh/ssh_host_rsa_key" > /etc/ssh/sshd_config
        #echo "HostKey inserted into 'sshd_config' in next case select."
        echo "This only generates and properly configures the host key permissions..."
    break;;
    "OpenSSH Server Config") #To be verified
        #pushd $(dirname "${0}") > /dev/null
        file="$(pwd -L)/configFiles/sshd_config"
        cd /etc/ssh/
        sudo mv sshd_config sshd_config.backup
        sudo cp ${file} sshd_config
        sudo chown root:root sshd_config
        sudo chmod 644 sshd_config
        banner="$(pwd -L)/configFiles/ssh_banner"
        sudo cp ${banner} ./
        sudo chown root:root ssh_banner
        sudo chmod 644 ssh_banner
        sudo service ssh restart
    break;;
    "SSH Port Knocking")
    read -p "Which port is OpenSSH using: " ssh_port
    read -p "Do you wish to continue (Y/n)" proceed
    #Once verified rewrite to: read -p "Stage X Port: " stageX_port
    stage1_port=3456
    stage2_port=2345
    door_port=1234
    if [ "$proceed" == "Y" || "y" || "yes" ]
    then
        $IPT -N stage1
        $IPT -A stage1 -m recent --remove --name knock
        $IPT -A stage1 -p tcp --dport ${stage1_port} -m recent --set --name knock2

        $IPT -N stage2
        $IPT -A stage2 -m recent --remove --name knock2
        $IPT -A stage2 -p tcp --dport ${stage2_port} -m recent --set --name heaven

        $IPT -N door
        $IPT -A door -m recent --rcheck --seconds 5 --name knock2 -j stage2
        $IPT -A door -m recent --rcheck --seconds 5 --name knock -j stage1
        $IPT -A door -p tcp --dport ${door_port} -m recent --set --name knock

        $IPT -A INPUT -m --state ESTABLISHED,RELATED -j ACCEPT
        $IPT -A INPUT -p tcp --dport ${ssh_port} -m recent --rcheck --seconds 5 --name heaven -j ACCEPT
        $IPT -A INPUT -p tcp --syn -j door

        echo "Port knocking for ${ssh_port} enabled"
        echo "Sequence order: ${stage1_port}, ${stage2_port}, ${door_port}" > /tmp/sequence_${ssh_port}.txt
      else
        echo "Port knocking has NOT been enabled!"
        echo "Now returning to main menu..."
      fi
    break;;
    "Apache SSL Mods and Sites") #To be verified
        #pushd $(dirname "${0}") > /dev/null
        file="$(pwd -L)"
        https="${file}/configFiles/https.conf"
        https_sws="${file}/configFiles/https_sws.conf"
        http_redirect="${file}/configFiles/000-redirect.conf"
        nextcloud_https="${file}/configFiles/nextcloud.https.conf"
        nextcloud_https_sws="${file}/configFiles/nextcloud.https_sws.conf"
        cd /etc/apache/sites-available/
        sudo cp ${https} ./
        sudo cp ${https_sws} ./
        sudo cp ${http_redirect} ./
        sudo cp ${nextcloud_https} ./
        sudo cp ${nextcloud_https_sws} ./
        sudo touch 80-http.conf ./  #This is a blank file
        sudo chown -R root:root /etc/apache/sites-available/
        sudo chmod -R 644 /etc/apache/sites-available/
    #Mods
        cd /etc/apache/mods-available/
        sudo a2enmod ssl
    #Sites
        cd /etc/apache/sites-available/
        sudo a2ensite 000-redirect.conf
        sudo a2ensite nextcloud.https.conf
        sudo a2ensite nextcloud.https_sws.conf
    break;;
    "Apache Let's Encrypt")
    #Auto configure HTTPS from where
    #Ensure cert and private key have proper permissions.
        #Public keys  -rw-r--r--   root root
        #Private keys -rw-------   root root
    #Note that anything owed by root is given write permissions
    #This is due to root being a superuser and can bypass 000
    break;;
    "Tor Hidden Service")
        #pushd $(dirname "${0}") > /dev/null
        file="$(pwd -L)"
        apacheConfig="${file}/configFiles/hidden_service.conf"
        torrcConfig="${file}/config/Files/torrc"
        sudo cp ${apacheConfig} /etc/apache/sites-available/
        sudo mv /var/lib/tor/torrc /var/lib/tor/torrc.backup
        sudo cp ${torrcConfig} /var/lib/tor/torrc
        sudo a2ensite /etc/apache/sites-available/hidden_service.conf
        sudo service apache2 restart
        sudo service tor restart
    break;;
    #"Option 3")
    #echo "you chose choice $REPLY which is $opt"
    #break;;
    "Auto Install") #Complete
        echo "This will install the following:
        Apache2
        Chrootkit
        Fail2Ban
        MySQL Server
        OpenSSH Server
        PHP-7.2 with MySQL Module
        RKHunter
        Snort
        Tor client
        "
        read -p "Do you wish to continue (Y/n)" proceed
        if [ "$proceed" == "Y" || "y" || "yes" ]
        then
        sudo apt update
        sudo apt install apache2 -y
        sudo apt install chrootkit -y
        sudo apt install fail2ban -y
        sudo apt install mysql-server -y
        sudo apt install php && php-mysql -y
        sudo apt install openssh-server -y
        sudo apt install rkhunter -y
        sudo apt install snort -y
        sudo apt install tor -y
        echo "Applications install. Consider running: apt upgrade."
      else
        echo "Now returning to main menu..."
      fi
    break;;
    "Fail2Ban Config")
        #pushd $(dirname "${0}") > /dev/null
        file="$(pwd -L)/configFiles/jail.local"
        cd /etc/fail2ban/
        sudo cp ${file} jail.local
        #sudo chown root:root ${file}
        #sudo chmod 551 ${file}
        sudo service fail2ban restart
    break;;
    "Snort - Realtime notify")
    #This uses a patched version of NotifyOSD
        #pushd $(dirname "${0}") > /dev/null
        file="$(pwd -L)/configFiles/snort_notifications.sh"
        cd /opt/
        sudo cp ${file} ./snort_notifications.sh
        sudo chmod 551  ./snort_notifications.sh
        sudo chown root:root ./snort_notifications.sh
        sudo echo "/opt/snort_notifications.sh" > /etc/init.d/rc.local
    break;;
    "Install patched NotifyOSD")

    break;;
    "Secure Shared Memory")
        sudo echo "tmpfs /run/shm tmpfs defaults,noexec,nosuid 0 0" >> /etc/fstab
        echo "Shared memory secured..."
    break;;
    "Unattended Upgrades - APT")
        sudo apt update
        sudo apt install unattended-upgrades apt-listchanges bsd-mailx
        # https://www.cyberciti.biz/faq/how-to-keep-debian-linux-patched-with-latest-security-updates-automatically/
    break;;
    "Secure GRUB Boot Loader")
        sudo grub-md5-crypt > /boot/grub/menu.lst
        sudo more /boot/grub/menu.lst
        echo "GRUB password hash written to menu.lst"
    break;;
    "Check for empty password accounts")
        sudo awk -F: '($2 == "") {print}' /etc/shadow
        echo "To lock any accounts use: 'passwd -l accountName'"
    break;;
    "Check if UID Set To 0")
        echo "You should only see one line."
        sudo awk -F: '($3 == "0") {print}' /etc/passwd
    break;;
    "View Open Ports")
        netstat -tulpn
    break;;
    "Harden Networking Layer")

    break;;
    "Prevent IP Spoofing")
        file="$(pwd -L)/configFiles/host.conf"
        cd /etc/
        sudo mv host.conf host.conf.backup
        sudo cp ${file} host.conf
    break;;
    "")
          #Example
    break;;
        "Quit")
        echo "Goodbye... :~)\n"
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
fi
