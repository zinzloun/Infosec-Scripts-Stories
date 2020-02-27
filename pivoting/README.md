# Tools
1. nmap compiled with limited features. All the glory goes to: https://github.com/andrew-d/static-binaries/tree/master/binaries/windows/x86
- I was able to use only connected scan -sT and I need to provide the --unprivileged options, e.g. nmap -sT -n -PN -p- -v --unprivileged <target>
2. arp_scan, again thanx to: https://github.com/QbsuranAlang/arp-scan-windows-
  - arp-scan.exe -t <subnet>

# Scripts & Commands
- CMD DOS ping sweep (192.168.1.0/254), redirect output to a file
  └──╼ FOR /L %i in (1,1,254) do @ping -n 1 -w 200 192.168.1.%i | find "TTL" >> %temp%\Ping_Sweep_Results.txt
- Shell ping sweep same subnet
  └──╼ for i in {1..254}; do ping -c 1 192.168.1.$i | grep "from" | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b"; done

