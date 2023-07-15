#!/bin/bash

if [ "`id -u`" != "0" ]
then
    echo "Script needs root - use sudo bash ConfigureDNS.sh"
    echo "Cannot continue."
    exit 5
fi

sudo apt-get install bind9-dnsutils -y

got_them=0
while [ $got_them -lt 1 ]
do
    go_back=0
    clear
    exec 3>&1
    Values=$(dialog --colors --ok-label "Submit" --form "       \Zr Developed by the xDrip team \Zn\n\n\n\
Enter your hostname (e.g., nightscout.example.com - needs to be a subdomain!) and IP address (e.g., 34.111.222.12)." 12 50 0 "User ID:" 1 1 "$hostname" 1 14 25 0 "Password:" 2 1 "$ipaddress" 2 14 25 0 2>&1 1>&3)
    response=$?
    if [ $response = 255 ] || [ $response = 1 ] # canceled or escaped
    then
        clear
        exit 5
    fi

    exec 3>&-
    hostname=$(echo "$Values" | sed -n 1p)
    ipaddress=$(echo "$Values" | sed -n 2p)

    if [ "$hostname" = "" ] || [ "$ipaddress" = "" ] #  At least one parameter is blank. 
    then
        go_back=1
        clear
        dialog --colors --msgbox "       \Zr Developed by the xDrip team \Zn\n\n\
You need to enter both hostname and IP address.  Try again."  8 50
    fi
    clear

    if [ $go_back -lt 1 ]
    then
        if [[ "$ipaddress" =~ ^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$ ]]
        then
            dialog --colors --msgbox "       \Zr Developed by the xDrip team \Zn\n\n\
Your IP address does not have the right format, it should look like, e.g., 34.111.222.12\n\n\
Please try again." 16 50
            go_back=1
        else
            got_them=1 # We have the hostname and IP address
        fi
    fi
done
clear

#create a file to store the data for the startup script.
cat> /etc/free-dns.sh<<EOF
#!/bin/sh
export HOSTNAME=$hostname
export DIRECTURL=$ipaddress
EOF

# Start the first update immediately
wget -O - --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 $ipaddress

#Add the command to renew the script to the startup url
if ! grep -q "DIRECTURL" /etc/rc.local; then
    echo . /etc/free-dns.sh >>  /etc/rc.local
    echo wget -O /tmp/freedns.txt --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 \$DIRECTURL >>  /etc/rc.local
    echo exit 0 \# This should be the last line to ensure the startup will complete. >> /etc/rc.local
fi

dialog --colors --msgbox "       \Zr Developed by the xDrip team \Zn\n\n\
Press enter to proceed.  Please be patient as it may take up to 10 minutes to complete." 8 50
clear
# wait for the ip to be updated. This might take up to 10 minutes.
cnt=0
while : ; do
    sleep 30
    registered=$(nslookup $hostname|tail -n2|grep A|sed s/[^0-9.]//g)
    current=$(wget -q -O - http://checkip.dyndns.org|sed s/[^0-9.]//g)
    echo $current $registered
    [[ "$registered" != "$current" ]] || break
    cnt=$((cnt+1))
    echo $cnt
    if (( cnt%6 == 0 )); then
        echo "ccc" $cnt
        wget -O - --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 $directurl
    fi
    sudo systemd-resolve --flush-caches
    ping -c 1 $hostname
    sudo systemd-resolve -4 $hostname
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

    sudo certbot --nginx -d "$hostname" --redirect --agree-tos --no-eff-email

    if [ ! -s /etc/letsencrypt/live/"$hostname"/cert.pem ] || [ ! -s /etc/letsencrypt/live/"$hostname"/privkey.pem ]
    then
         echo DNS failed sleeping 
         sleep 60
    else
        # worked, geting out of the loop.
        exit 1
    fi
done
cat > /tmp/FreeDNS_Failed << EOF
Internal error.  Must run DNS setup again.
EOF

dialog --colors --msgbox "       \Zr Developed by the xDrip team \Zn\n\nInternal error.  Press enter to exit.  Then, run \"Install Nightscout phase 2\" again." 8 50
