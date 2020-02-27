#!/usr/bin/python

import threading
import socket
import sys

target = sys.argv[1]
print('IP ',target,'-----------')

def portscan(port):

    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(0.5)# 

    try:
        con = s.connect((target,port))

        print('Port :',port,"is open.")

        con.close()
    except: 
        pass
r = 1 
# first 1000 ports
for x in range(1,1000): 

    t = threading.Thread(target=portscan,kwargs={'port':r}) 

    r += 1     
    t.start() 
