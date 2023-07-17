#!/bin/bash

if [ "`id -u`" != "0" ]
then
echo "Script needs root - use sudo bash DNS-config.sh"
echo "Cannot continue."
exit 5
fi

# Start the first update immediately
wget -O - --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 $DIRECTURL

#Add the command to renew the script to the startup url
if ! grep -q "DIRECTURL" /etc/rc.local; then
    echo . /etc/dns-config.sh >>  /etc/rc.local
    echo wget -O /tmp/dns-config.txt --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 \$DIRECTURL >>  /etc/rc.local
    echo exit 0 \# This should be the last line to ensure the startup will complete. >> /etc/rc.local
fi

dialog --colors --msgbox "       \Zr Developed by the xDrip team \Zn\n\n\
Press enter to proceed.  Please be patient as it may take up to 10 minutes to complete." 8 50
clear
# wait for the ip to be updated. This might take up to 10 minutes.
cnt=0
while : ; do
    sleep 30
    registered=$(nslookup $HOSTNAME|tail -n2|grep A|sed s/[^0-9.]//g)
    current=$(wget -q -O - http://checkip.dyndns.org|sed s/[^0-9.]//g)
    echo $current $registered
    [[ "$registered" != "$current" ]] || break
    cnt=$((cnt+1))
    echo $cnt
    if (( cnt%6 == 0 )); then
         echo "ccc" $cnt
        wget -O - --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 $DIRECTURL
    fi
    sudo systemd-resolve --flush-caches
    ping -c 1 $HOSTNAME
    sudo systemd-resolve -4 $HOSTNAME
    if [ $cnt -gt 20 ]
    then
      clear
      dialog --colors --msgbox "       \Zr Developed by the xDrip team \Zn\n\n\
Please close this window.  Open a new SSH terminal.  Run DNS Setup again to complete DNS setup." 9 50
      exit
    fi
done

#Fix the certificate using the new host name.


for i in {1..4}
do
    for j in {1..1000}
    do
    read -t 0.001 dummy
    done

    sudo certbot --nginx -d "$HOSTNAME" --redirect --agree-tos --no-eff-email

    if [ ! -s /etc/letsencrypt/live/"$HOSTNAME"/cert.pem ] || [ ! -s /etc/letsencrypt/live/"$HOSTNAME"/privkey.pem ]
    then

         echo freedns failed sleeping 
         sleep 60
    else
        # worked, geting out of the loop.
        exit 1
    fi
done
cat > /tmp/DNS-config_Failed << EOF
Internal error.  Must run DNS setup again.
EOF

dialog --colors --msgbox "       \Zr Developed by the xDrip team \Zn\n\nInternal error.  Press enter to exit.  Then, run \"Install Nightscout phase 2\" again." 8 50

else  # If DNS is down
dialog --colors --msgbox "       \Zr Developed by the xDrip team \Zn\n\n\
It seems the DNS site is down.  Please try again when DNS is back up." 9 50
cat > /tmp/DNS-config_Failed << EOF
The DNS site is down.
EOF
fi
