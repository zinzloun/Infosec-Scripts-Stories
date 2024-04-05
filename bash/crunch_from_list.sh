#!/bin/bash
cecho(){
    RED="\033[1;31m"
    GREEN="\033[0;32m"  # <-- [0 means not bold
    YEL="\033[1;33m" # <-- [1 means bold

    NC="\033[0m" # No Color

    echo -e "${!1}${2} ${NC}"
}

if ! command -v crunch &> /dev/null
then
    cecho "RED" "crunch could not be found"
    exit 1
fi

if [ -z "$1" ]
  then
    cecho "YEL" "No input file provided, please use the following command: $0 /path/to/file"
    exit 1
fi

if [ ! -e "$1" ]; then
    cecho "RED" "File $1 does not exist"
    exit 1
fi 

n_rows=$(sed -n '$=' $1)
i=0
ts=$(date "+%Y.%m.%d-%H.%M.%S")
output="password_lst_$ts.txt"
echo "crunch is generated the password list using the following criteria: append a number (0-9) and a special character to each line found in the file $input"
echo "it could take very long time, so grab a beer and be patient :)"

while IFS= read -r line
do
 
 len=${#line}
 len=$((len+2))
 crunch $len $len -t $line%^ >> $output
 
 i=$((i+1))
 cecho "GREEN" "....combinations created for $line: $i/$n_rows"

done < "$1"
# OPTIONAL ##########################################################################
cecho "YEL" "Clean up the file, I will keep only the passwords that ends with !@#$%^"
sed -i '/[^!@#$%^]$/d' $output
######################################################################################

cecho "GREEN" "Total passwords generated: $(wc -l < $output)"
cecho "GREEN" "Password list created. The list is saved as $PWD/$output"
