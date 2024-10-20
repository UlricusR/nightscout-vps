#!/bin/bash

echo
echo "Install packages. - Navid200"
echo

# Reduce the number of snapshots kept from the default 3 to 2 to reduce disk space usage.
sudo snap set system refresh.retain=2

# Let's upgrade packages if available and install the missing needed packages.
sudo apt-get update

#Ubuntu upgrade available
NextUbuntu="$(apt-get -s upgrade | grep 'Inst base' | awk '{print $4}' | sed 's/(//')"
if [ "$NextUbuntu" = "11ubuntu5.8" ] # Only upgrade if we have tested the next release
then
  sudo apt-get -y upgrade
fi

# packages
whichpack=$(which file)
if [ "$whichpack" = "" ]
then
  sudo apt-get -y install vis nano screen jq qrencode file net-tools gnupg liblzma5 apt-transport-https lsb-release ca-certificates build-essential
fi

# mongo
whichpack="$(mongod --version | sed -n 1p)"
if [ ! "${whichpack%%.*}" = "db version v3" ]
then
  sudo apt-get -y install mongodb-server
fi  

# node - We install version 16 of node here, which automatically  updates npm to 8.
whichpack=$(node -v)
if [ ! "${whichpack%%.*}" = "v16" ]
then
sudo /xDrip/scripts/nodesource_setup.sh
# sudo apt install -y nodejs
sudo apt-get install nodejs -y
# Nightscout needs version 6 of npm.  So, we are going to install that version now effectivwely downgrading it.  
sudo npm install -g npm@6.14.18
fi

# The last item on the above list of packages must be verified in Status.sh to have been installed.  

# Add log
/xDrip/scripts/AddLog.sh "The packages have been installed" /xDrip/Logs
  
