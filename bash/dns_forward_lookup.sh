#!/bin/sh
#DNS Forward lookup using the host command
#
if [ $# -ge 3 ]
then
	#echo $1
	#echo $2
	for name in $(cat $1); do host $name.$3 $2 -W 2; done | grep 'has address'
else
	echo You must pass 3 arguments: 1 host names list file e.g. zinzloun.txt, 2 DNS IP address e.g. 8.8.8.8, 3 domain name: e.g. zinzloun.info
fi
