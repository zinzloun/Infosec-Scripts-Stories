#!/bin/bash

# This script clean up a wordlist created with cewel (required)
#  you must provide a valid url

if [[ $# -eq 0 ]] ; then
    echo "You must provide a valid URL. Usage $0 <URL>"
    exit 1
fi

echo "Generating the wordlist from $1..."
#-d 0: do not follow any link in the page
cewl "$1" -d 0 -w tmp_wl.txt
# clean up the result for wikipedia derived wl 1
echo "done. Clean up the result..."
cat tmp_wl.txt | grep "\w\{7,\}" | grep -v "^wg" | head -n -50 > tmp_wl1.txt
# get only character class
grep -P '^[[:ascii:]]+$' tmp_wl1.txt > aniceWL.txt
#clean up files
rm tmp_wl*.txt
echo "The wordlist has been created: aniceWL.txt"
