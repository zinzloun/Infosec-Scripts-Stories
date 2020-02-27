#Tools
1. nmap compiled with limited features. All the glory goes to: https://github.com/andrew-d/static-binaries/tree/master/binaries/windows/x86
- I was able to use only connected scan -sT and I need to provide the --unprivileged options, e.g. nmap -sT -n -PN -p- -v --unprivileged <target>
2. arp_scan, again thanx to: https://github.com/QbsuranAlang/arp-scan-windows-
