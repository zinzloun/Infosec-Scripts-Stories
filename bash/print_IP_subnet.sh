#!/bin/bash
#modify the subnet address 172.16.5. and the range 1..254
for IP in 172.16.5.{1..254}
do
   echo $IP
done
