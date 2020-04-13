# Tools
1. nmap compiled with limited features. All the glory goes to: https://github.com/andrew-d/static-binaries/tree/master/binaries/windows/x86
- You can perform only connected scan -sT. If you are logged as unprivileged user you may have to pass the corresponding option:<br><b>nmap -sT -n -Pn -p- -v --unprivileged target</b><br>If you are a previleged user you can skip it.
2. arp_scan, again thanx to: https://github.com/QbsuranAlang/arp-scan-windows-<br>
  - arp-scan.exe -t subnet
3. port_scan.py, a simple Python port scan on ports 1-1000, you must pass an IP as argument
- ./port_scan.py IP
4. winscppwd.exe, reverse the saved SCP client password presenti in a in file<br/>winscppwd.exe mySCPFile.ini

# Scripts & Commands
- CMD DOS ping sweep (192.168.1.0/254), redirect output to a file<br>
  └──╼ FOR /L %i in (1,1,254) do @ping -n 1 -w 200 192.168.1.%i | find "TTL" >> %temp%\Ping_Sweep_Results.txt
- Shell ping sweep same subnet<br>
  └──╼ for i in {1..254}; do ping -c 1 192.168.1.$i | grep "from" | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b"; done

