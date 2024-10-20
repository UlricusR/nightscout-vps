#!/bin/bash

echo
echo "Log into the FreeDNS site. - Navid200"
echo

# This could also run in the background.  So, it should contain no dialog.
# All the logs this utility generates are stored in an auto-login dedicated log file separate from the main system logs.

freedns=$(wget --spider -S "https://freedns.afraid.org/" 2>&1 | awk '/HTTP\// {print $2}') # This will be 200 if FreeDNS is up.
if [ $freedns -eq 200 ]  # Run the following only if FreeDNS is up.
then 
  if [ -s /xDrip/FreeDNS_ID_Pass ] # If the FreeDNS_ID_Pass file exists
  then
    . /xDrip/FreeDNS_ID_Pass
    user=$User_ID
    pass=$Password
    arg1="https://freedns.afraid.org/api/?action=getdyndns&v=2&sha="
    arg2=$(echo -n "$user|$pass" | sha1sum | awk '{print $1;}')
    arg="$arg1$arg2"
    wget -O /tmp/hosts "$arg"
    rm -rf /xDrip/FreeDNS_Fail
    if [ ! "`grep 'Could not authenticate' /tmp/hosts`" = "" ] # Failed to log in
    then
      # Log.
      /xDrip/scripts/AddLog.sh "Login to FreeDNS failed autherntication." /xDrip/FreeDNS_AutoLogin_Logs
      cat > /xDrip/FreeDNS_Fail << EOF
FreeDNS failed authentication.
EOF
    else
      # Log.
      /xDrip/scripts/AddLog.sh "Logged into FreeDNS." /xDrip/FreeDNS_AutoLogin_Logs
    fi
  else
    # Log.
    /xDrip/scripts/AddLog.sh "The /xDrip/FreeDNS_ID_Pass file does not exist." /xDrip/FreeDNS_AutoLogin_Logs
    cat > /xDrip/FreeDNS_Fail << EOF
FreeDNS_ID_Pass file does not exist.
EOF

  fi
else
  # Log.
  /xDrip/scripts/AddLog.sh "The FreeDNS site seems to be down." /xDrip/FreeDNS_AutoLogin_Logs
fi
 
