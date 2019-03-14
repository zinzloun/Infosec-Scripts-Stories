=begin
 *** ICMP ping sweep of a net segment as xxx.xxx.xxx. ***
 *** Required gems: net-ping, win32-security (on windows only) ***
 *** v. 1.0 coded by Zinzloun ***
=end

#import gem
require 'net/ping'
if ARGV.empty?
  puts "Usage: sweep.rb <net segment e.g. 192.168.1.> [-v print number of alive hosts] [-f redirect output to a file named sweep.txt]"
  exit 1
end

puts "*** Sweep started, please wait... ***\n"
#get the net segment
net_seg = ARGV[0]
#default ping timeout (optional) is 1 second, decreased it to speed up
timeout = 0.15
#counter live hosts
ip_count = 0
#hosts log printed eventually (-f) to the output file
output_s = ""

#subnet range loop
(1..254).each do |ip|
 #ping the current host
 req = Net::Ping::ICMP.new(net_seg + ip.to_s,nil,timeout)
 #check is alive
 if req.ping
	output_s += net_seg + ip.to_s + "\n"
	puts net_seg + ip.to_s
	ip_count += 1
 end
end

#verbose
if ARGV.include?("-v")
 puts "Alive hosts: " + ip_count.to_s
end

#write output to the file
if ARGV.include?("-f")
 begin
  file = File.open("./sweep.txt", "w")
  file.write(output_s)
  puts "Scan result saved in .sweep.txt"
 rescue IOError => e
  #some error occur, dir not writable etc...
  puts "An error occured creating the sweep output file. " + e.to_s
 ensure
  file.close unless file.nil?
 end
end

