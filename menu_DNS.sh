#!/bin/bash

echo
echo "Bringing up the Nightscout setup menu" - UlricusR
echo

clear
Choice=$(dialog --colors --nocancel --nook --menu "\
        \Zr Developed by the xDrip team \Zn\
  \n\n
Use the arrow keys to move the cursor.\n\
Press Enter to execute the highlighted option.\n" 14 50 4\
 "1" "Use FreeDNS"\
 "2" "Directly enter own hostname and IP address"\
 "3" "Return"\
 3>&1 1>&2 2>&3)

case $Choice in


1)
sudo /xDrip/scripts/ConfigureFreedns.sh
;;

2)
sudo /xDrip/scripts/ConfigureDNS.sh
;;

3)
;;

esac
  
