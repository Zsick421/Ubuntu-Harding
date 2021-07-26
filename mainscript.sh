#!/bin/bash

#setup

echo "run this as root"
echo "did you finish forensics"

read varanswer

if [ "$varanswer" = yes ]; then
  echo "starting script "
else 
  exit 
fi

#load config files
source ubuntuscript.config 

#updates
     if [ "$UPDATES" = true ]; then
    echo "getting updates"
    apt-get update -y
fi

#firewall
    if [ "$FIREWALL" = true ]; then
    echo "enableing firewall"
    ufw enable 
fi

#open ssh
    if [ "$SSH" = true ]; then 
    echo "installing open-ssh"
    apt-get install openssh-server
fi
 
#upgarde packages
    if [ "$UPGRADE" = true ]; then
    echo "upgarding packages"
    apt-get dist-upgrade
fi

#pureftp
  if [ "$FTP" = true ]; then
    echo "deleting ftp"
    apt-get remove ftp 
    apt-get remove pure-ftp
fi

#bad programs
  if [ "$BADP" = true ]; then
    echo "deleting bad programs"
    apt-get remove nmap
    apt-get remove zanmap
    apt-get remove john
    apt-get remove netcat
    apt-get remove wireshark
    apt-get remove ophcrack
fi

#Password aging policy
  if [ "$PSAGE" = true ]; then
    echo "setting passwords to reset after 30 days"
    PASSMAX="$(grep -n 'PASS_MAX_DAYS' /etc/login.defs | grep -v '#' | cut -f1 -d:)"
    sed -e "${PASSMAX}s/.*/PASS_MAX_DAYS	90/" /etc/login.defs > /var/local/temp1.txt
    PASSMIN="$(grep -n 'PASS_MIN_DAYS' /etc/login.defs | grep -v '#' | cut -f1 -d:)"
    sed -e "${PASSMIN}s/.*/PASS_MIN_DAYS	10/" /var/local/temp1.txt > /var/local/temp2.txt
    PASSWARN="$(grep -n 'PASS_WARN_AGE' /etc/login.defs | grep -v '#' | cut -f1 -d:)"
    sed -e "${PASSWARN}s/.*/PASS_WARN_AGE	7/" /var/local/temp2.txt > /var/local/temp3.txt
    mv /etc/login.defs /etc/login.defs.old
    mv /var/local/temp3.txt /etc/login.defs
    rm /var/local/temp1.txt /var/local/temp2.txt
fi 

#Password Lockout
  if [ "$PSLOCKOUT" = true ]; then
    echo "Enabling account lockout"
    cp /etc/pam.d/common-auth /etc/pam.d/common-auth.old
    echo "auth required pam_tally2.so deny=5 onerr=fail unlock_time=1800" >> /etc/pam.d/common-auth
fi 

#SSH daemon config
  if [ "$DISABLE_ROOT_SSH" = true ]; then
    echo "disabling root login"

    #get the line number of the PermitRootLogin line
    PRL="$(grep -n 'PermitRootLogin' /etc/ssh/sshd_config | grep -v '#' | cut -f1 -d:)"
    sed -e "${PRL}s/.*/PermitRootLogin no/" /etc/ssh/sshd_config > /var/local/temp1.txt
    mv /etc/ssh/sshd_config /etc/ssh/sshd_config.old
    mv /var/local/temp1.txt /etc/ssh/sshd_config
fi 

#Disable the guest account
  if [ "$DISABLE_GUEST" = true ]; then
    echo "disabling guest account"
    cp /etc/lightdm/lightdm.conf /etc/lightdm/lightdm.conf.old
    echo "allow-guest=false" >> /etc/lightdm/lightdm.conf
fi 

#Find all video files
  if [ "$MEDIA_LOCATIONS" = true ]; then
    echo "Finding Media Files"
    echo "||||Video Files||||" >> /var/local/mediafiles.log
    locate *.mkv *.webm *.flv *.vob *.ogv *.drc *.gifv *.mng *.avi$ *.mov *.qt *.wmv *.yuv *.rm *.rmvb *.asf *.amv *.mp4$ *.m4v *.mp *.m?v *.svi *.3gp *.flv *.f4v >> /var/local/mediafiles.log
    echo "||||Audo Files||||" >> /var/local/mediafiles.log
    locate *.3ga *.aac *.aiff *.amr *.ape *.arf *.asf *.asx *.cda *.dvf *.flac *.gp4 *.gp5 *.gpx *.logic *.m4a *.m4b *.m4p *.midi *.mp3 *.pcm *.rec *.snd *.sng *.uax *.wav *.wma *.wpl *.zab >> /var/local/mediafiles.log
    echo "||||Photo Files||||" >> /var/local/mediafiles.log
    locate *.gif *.png *.jpg *.jpeg >> /var/local/mediafiles.log
fi 

#Log items that could help with forensics
  if [ "$FORENSICS_LOG" = true ]; then
    cd "Desktop"
    cat /etc/passwd > user
    cat /etc/group > group
    cat /etc/crontab > task
    Initctl list
    apt list installed > packages
    service --status-all
    netstat -ln > network\
fi
#Lists all cronjobs & output to /var/local/cronjoblist.log
  if [ "$LOG_CRON" = true ]; then
    echo "Outputting cronjobs to /var/local/cronjoblist.log"
    crontab -l >> /var/local/cronjoblist.log
fi 

#List all processes & output to /var/local/pslist.log
  if [ "$PS_LOG" = true ]; then
    echo "Outputting processes to /var/local/pslist.log"
    ps axk start_time -o start_time,pid,user,cmd >> /var/local/pslist.log
fi 

#List all connections, open or listening
  if [ "$LOG_NETSTAT" = true ]; then
    echo "finding open connections and outputting to /var/local/netstat.log"
    ss -an4 > /var/local/netstat.log
fi 

#Install clam antivirus
  if [ "$INSTALL_CLAM" = true ]; then
    echo "installing clam antivirus"
    apt-get install clamav -y
fi 

#Run clamav
  if [ "$CLAM_HOME" = true ]; then
    
  #Update clam signatures
    echo "updating clam signatures"
    freshclam

   #Run a full scan of the "/home" directory
    echo "running full scan of /home directory"
    clamscan -r /home
fi 

echo "script complete"
