#!/bin/bash

echo
echo "Backing up the mongoDB database - tzachi-dar"
echo

while :
do
exec 3>&1
Filename=$(dialog --colors --ok-label "Submit" --form "       \Zr Developed by the xDrip team \Zn\n\n\n\
Enter a name for the backup file" 11 50 0 "file name" 1 1 "$filename" 1 14 25 0 2>&1 1>&3)
 response=$?
if [ $response = 255 ] || [ $response = 1 ]
then
clear
exit
fi

if [ -s $Filename ]
then
dialog --colors --msgbox "       \Zr Developed by the xDrip team \Zn\n\n\n\
A file with the same name exists.\n\
Choose a different filename." 9 50
clear
else
mongodump --gzip --archive=/tmp/database.gz
exec 3>&-
cd /tmp
cp /etc/nsconfig .
tar -cf ~/$Filename database.gz nsconfig

 dialog --colors --infobox "       \Zr Developed by the xDrip team \Zn\n\n\n\
Backup is complete.\n\n\
Copy the full path to the backup file shown below, and click \"DOWNLOAD FILE\" above to download it.\n\n\
Press any key to return to the main menu." 13 50
cd ~ 
tput civis
echo ""
echo ""
echo ""
echo ""
readlink -f $Filename
# read -p "Press any key to continue... " -n1 -s
# read -p "Press Enter to continue... "  

read -p "" -n1 -s
tput cnorm
 
exit
fi
done 
 
