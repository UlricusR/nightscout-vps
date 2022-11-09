#!/bin/bash

echo
echo "Fetch the latest scripts from GitHub - Navid200"
echo

cd /tmp

#if [ -s ./nightscout-vps ] # Main
if [ -s ./cgm-remote-monitor ] # Navid's
then
#sudo rm -r nightscout-vps # If the directory already exists in the tmp directory, delete it.  Main
sudo rm -r cgm-remote-monitor # If the directory already exists in the tmp directory, delete it.  Navid's
fi

#sudo git clone https://github.com/jamorham/nightscout-vps.git # Clone the install repository.  Main
sudo git clone https://github.com/Navid200/cgm-remote-monitor.git # Clone the install repository.  Navid's
#cd nightscout-vps # Main
cd cgm-remote-monitor # Navid's
#sudo git checkout vps-1 # Main
sudo git checkout VerifyVM_Test # Navid's
sudo git pull
sudo chmod 755 *.sh # Change premissions to allow execution by all.
sudo mv -f *.sh /xDrip/scripts # Overwrite the scripts in the scripts directory with the new ones.
cd ..
#sudo rm -r nightscout-vps # Delete the temporary pull directory. # Main
sudo rm -r cgm-remote-monitor # Delete the temporary pull directory. # Navid's

if [ ! -s /tmp/nodialog_update_scripts ]
then
dialog --colors --msgbox "    \Zr Developed by the xDrip team \Zn\n\n\
Updated scripts will be in effect in a new window." 8 43
clear
fi
 
