=begin
 TCP SYN PORT SCANNER for an IP and a port range, eventually print the result in a file
  e.g. 10.100.2.14 1-500 
 returns the state of scanned ports
=end

require 'packetfu'

include PacketFu

PROG_NAME = "ruby packetfu_port_scanner.rb"

#using a parallel thread
def start_capture(host,start_port,end_port)
	open=[]; closed=[]
	Thread.new{
		cap = Capture.new
		#filter rule ro capture packet
		cap.capture(:filter => ("tcp and src host "+host) )
		cap.stream.each do |rw|
				tcp_packet = Packet.parse(rw)
				port = tcp_packet.tcp_sport.to_i
				next if !port.between?(start_port,end_port)
				flags = tcp_packet.tcp_flags
				#port is open
				open.push(port) if (flags.syn==1 && flags.ack==1 && !open.include?(port)) 
				#port is closed
				closed.push(port) if (flags.rst==1 && flags.ack==1 && !open.include?(port))
		end
	}
	#returns open and closed matrix of arrays
	return open, closed
end

def send_tcp_syn(host,start_port,end_port)
	t = TCPPacket.new(:config => Utils.whoami?)
	d_mac = Utils.arp(host) 
	if d_mac 
		t.eth_daddr = d_mac
	else
		t.eth_daddr = Utils.whoami?[:eth_daddr]
	end
	t.ip_daddr = host
	t.tcp_flags.syn = 1
	start_port.upto(end_port) do |port|
		t.tcp_dport = port			
		t.recalc
		#send the packet 2 times
		2.times.each { 
			t.to_w;
			sleep(0.05)
		}
	end
	sleep(1)
end

def write_to_file(message)
 begin
  file = File.open("./fu_scan_result.txt", "w")
  file.write(message)
  puts "\nScan result saved in ./fu_scan_result.txt"
 rescue IOError => e
  #some error occur, dir not writable etc...
  puts "\nAn error occured creating the output file. " + e.to_s
 ensure
  file.close unless file.nil?
 end
end


############################# start of PROGRAM'S LOGIC #####################

if ARGV.length < 2
 puts "Usage " + PROG_NAME + " <IP> <start_port-end_port> [-f print the output even in a file]"
 puts " Example:\n\t" + PROG_NAME + " 10.100.2.14 1-500"
 puts " Example: saving the output\n\t" + PROG_NAME + " 10.100.2.14 1-500 -f"  
 exit 1
end

host = ARGV[0]
port_range = ARGV[1]
#get start and end port
start_port,end_port = port_range.split("-").map{|idx| idx.to_i}


#start the capture in a new thread
#return a matrix with open and closed ports
#index 0 = open
#index 1 = closed
open_closed = start_capture(host,start_port,end_port)
#####################################################

#probe the ports
send_tcp_syn(host,start_port,end_port)
######################################

#if the ports are not open or close we infer they are filtered
#|_how wonderful is ruby with arrays ;)
filtered = (start_port..end_port).to_a - (open_closed[0] + open_closed[1])

#result = banner
puts "Scan result for IP " + host + ", ports " + port_range

#contain the output
result = ""

#result = ports...
# open

if !open_closed[0].empty?
 result = "\nOpen ports " + open_closed[0].to_s 
 result += "\n|_Total: " + open_closed[0].length.to_s + "\n"
end
# filtered
if !filtered.empty?
 result += "\nFiltered ports " + filtered.to_s
 result += "\n|_Total: " + filtered.length.to_s + "\n"
end
# closed
if !open_closed[1].empty?
 result += "\nClosed ports " + open_closed[1].to_s
 result += "\n|_Total: " + open_closed[1].length.to_s + "\n"
end

#print result on the screen
puts result

#print file check
write_to_file(result) if ARGV.include?("-f")






