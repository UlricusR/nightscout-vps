#!/bin/bash

# Requires two parameters.
# The first parameter is a line, in double quotes, that will be added to the top of the log file.
# The second parameter is the full path to the log file.
# This is an example call to this function:   /xDrip/scripts/AddLog.sh "This is my log" /directory/LogFile

if [ $# != 2 ]
then
  echo "Error: Incorrect number of parameters"
  exit 5
fi

sudo rm -rf /tmp/GCNS_Logs
echo -e "$1     $(date)\n" | cat - $2 > /tmp/GCNS_Logs
sudo /bin/cp -f /tmp/GCNS_Logs $2
if [ $? != 0 ]
then
  echo "Error: Failed to update logs"
  exit 5
fi
  
