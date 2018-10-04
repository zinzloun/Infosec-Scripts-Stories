#!/bin/bash
#You must have dig installed
#call the script in conjunction with grep, e.g.
#./reverse_DNS.sh | grep <domain: e.g. zinzloun.info> | grep PTR
if [ $# -ge 2 ]
then
	for ip in $(cat $1); do dig @$2 -x $ip +nocookie; done
else
	echo You must pass 2 arguments: 1 the IPs list file, 2 the DNS IP
fi
