#TCP forged packet using PacketFU with syn flag set
#to simulate a sS nmap scan and for fun, of course ;)

=begin
 Following the captured packets for [nmap -sS 10.100.2.14 -p135]
 10.100.2.67           10.100.2.14           TCP      58     36985 → 135 [SYN] Seq=0 Win=1024 Len=0 MSS=1460
 10.100.2.14           10.100.2.67           TCP      60     135 → 36985 [SYN, ACK] Seq=0 Ack=1 Win=64240 Len=0 MSS=1460
 10.100.2.67           10.100.2.14           TCP      54     36985 → 135 [RST] Seq=1 Win=0 Len=0

Following the captured packets using this procedure, same IP and port
 10.100.2.67           10.100.2.14           TCP      54     5000 → 135 [SYN] Seq=0 Win=16384 Len=0
 10.100.2.14           10.100.2.67           TCP      60     135 → 5000 [SYN, ACK] Seq=0 Ack=1 Win=65392 Len=0 MSS=1460
 10.100.2.67           10.100.2.14           TCP      54     5000 → 135 [RST] Seq=1 Win=0 Len=0
=end

require 'packetfu'
#include the NS
include PacketFu

FILE_name = "ruby packetfu_tcp_syn.rb"
#LOCAL PORT TO BE CONFIGURED HERE
SRC_port = 5000

#PARAMETER TO BE PASSED FROM THE COMMAND LINE
ip_dst = ""
dst_port = 0

if ARGV.length < 2 
	puts "Usage: " + FILE_name + " <Destination IP> <Destination PORT>\te.g. " + FILE_name + " 10.100.2.14 135"
	exit 1
else
	ip_dst = ARGV[0]
	dst_port = ARGV[1].to_i
end


#print whoami info
#wh = Utils.whoami?
#wh.each do |key, val|
 # puts key.to_s + " => " + val.to_s
#end

#config: to forge a packet we need to set the following:
# IP source address
# MAC source address
# Destination: default is the gateway MAC address for address outside our network (see comment below)--------
# get them from the local iface default config																 |		
uT = TCPPacket.new(:config=>Utils.whoami?)		#															 |
#since the ip_dst (target) is in our LAN we need to change the destination MAC address <---------------------
#that has to correspond to the destination IP, we can obtain it with a simple ARP request
uT.ip_daddr = ip_dst
uT.eth_daddr = Utils.arp(ip_dst)

#set the ports
uT.tcp_sport = SRC_port
uT.tcp_dport = dst_port
#and the syn flag
uT.tcp_flags.syn = 1

#print structure
puts uT.inspect

#LOOP TO retrasmitt the packet: default 1
for i in 1..1
 #recalculate the packet (always necessary)
 uT.recalc
 #send it
 uT.to_w
end

puts i.to_s + " packet[s] sent"




