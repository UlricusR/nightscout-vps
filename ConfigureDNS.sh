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
Enter your hostname and IP address." 12 60 0 "Hostname:" 1 1 "$hostname" 1 14 35 0 "IP address:" 2 1 "$ipaddress" 2 14 35 0 2>&1 1>&3)
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

export HOSTNAME=$hostname
export DIRECTURL=$ipaddress

#create a file to store the data for the startup script.
cat> /etc/dns-config.sh<<EOF
#!/bin/sh
export HOSTNAME=$hostname
export DIRECTURL=$ipaddress
EOF

