#!/bin/bash

if [ "`id -u`" != "0" ]
then
  echo "Script needs root - use sudo bash StartUpSetup.sh"
  echo "Cannot continue."
exit 5
fi

echo
echo "Set up startup - Navid200"
echo

## Updating the startup script

  cat > /etc/rc.local << "EOF"
#!/bin/bash
# This file is generated automatically.  It will be deleted and recreated.
# Please do not add anything to this file.
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"
cd /tmp
swapon /var/SWAP
service snapd stop
service mongodb start
screen -dmS nightscout sudo -u nobody bash /etc/nightscout-start.sh
service nginx start
. /etc/free-dns.sh
wget -O /tmp/freedns.txt --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 $DIRECTURL
exit 0 # This should be the last line to ensure the startup will complete.
EOF

# Add log
/xDrip/scripts/AddLog.sh "Updated the startup file" /xDrip/Logs
