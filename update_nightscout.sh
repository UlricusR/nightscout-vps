#!/bin/bash

echo
echo "Install Nightscout again, from the official repository or from a fork"
echo


if [ "`id -u`" != "0" ]
then
echo "Script needs root - execute bootstrap.sh or use sudo bash installation.sh"
echo "Cannot continue.."
exit 5
fi

if [ ! -s /var/SWAP ]
then
echo "Creating swap file"
dd if=/dev/zero of=/var/SWAP bs=1M count=2000
chmod 600 /var/SWAP
mkswap /var/SWAP
fi
swapon 2>/dev/null /var/SWAP

echo "Installing dialog"
sudo apt-get update
sudo apt-get -y install dialog

echo -e "use Nightscout\ndb.createUser({user: \"username\", pwd: \"password\", roles:[\"readWrite\"]})\nquit()" | mongo

# Setting the defaults
user="nightscout"
repo="cgm-remote-monitor"
brnch="master"

clear #  Clear the screen before placing the next dialog on.
dialog --yesno "Reinstall official Nightscout?\n\n
Choose Yes to install the latest version of official Nightscout.\n\n
Choose No to install from a fork (advanced).\n\n
Or, press escape to cancel." 14 50
ans=$?
if [ $ans = 255 ] # Exit if escape is pressed.
then
clear # Clear the screen before exiting.
echo "Escape"
echo "Cannot continue."
exit 5
elif [ $ans = 1 ] # We need Github details
then
# Clear fork parameters.
user=""
repo=""
brnch=""

# open fd
exec 3>&1

# Ask for the fork details. 
clear # Clear the screen before placing the next dialog on.
VALUES=$(dialog --ok-label "Submit" --form "Enter the GitHub details for the Nightscout version you want to install.\n" 12 50 0 "User ID:" 1 1 "$user" 1 14 25 0 "Repository:" 2 1 "$repo" 2 14 25 0 "Branch:" 3 1 "$brnch" 3 14 25 0 2>&1 1>&3)
ans2=$?
if [ $ans2 = 255 ] || [ $ans2 = 1 ] # Exit if escaped or cancelled
then
clear # Clear dialog.
echo "Escape or Cancel"
echo "Cannot continue."
exit 5
fi

# close fd
exec 3>&-

# display values just entered
#echo "$VALUES"
user=$(echo "$VALUES" | sed -n 1p)
repo=$(echo "$VALUES" | sed -n 2p)
brnch=$(echo "$VALUES" | sed -n 3p)
if [ "$user" = "" ] || [ "$repo" = "" ] || [ "$brnch" = "" ]
then
clear # clear before exiting
echo "Missing fork parameters"
echo "Cannot continue."
exit 5
fi
fi
clear  # Clear the last dialog

cd /
if [ -s ./nightscout_start ] # Delete the startup directory if it exists.
then
sudo rm -r nightscout_start
fi
sudo mkdir nightscout_start
cd /nightscout_start

combined="https://github.com/$user/$repo.git" # This is the path to the repository we are installing from
sudo git clone $combined

# Kill Nightscout
sudo pkill -f SCREEN
cd $repo
sudo git checkout $brnch
sudo git pull

sudo npm install
sudo npm run postinstall


cat> /etc/nightscout-start.sh<<EOF

#!/bin/sh
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
. /etc/nsconfig
export MONGO_COLLECTION="entries"
export MONGO_CONNECTION="mongodb://username:password@localhost:27017/Nightscout"
export INSECURE_USE_HTTP=true
export HOSTNAME="127.0.0.1"
export PORT="1337"
cd /nightscout_start/$repo
EOF

cat>> /etc/nightscout-start.sh<< "EOF"

while [ "`netstat -lnt | grep 27017 | grep -v grep`" = "" ]
do
echo "Waiting for mongo to start"
sleep 5
done
sleep 5
while [ 1 ]
do
node server.js
sleep 30
done
EOF
