=begin
 *** Scan a range port of a given host ***
 *** v. 1.0 Zinzloun ***
 *** Multi thread approach and time setting ***
 *** Issues: 
		the script is very time consuming, generally not efficient. It should be used only in a test enviroment ***
=end

#in std ruby lib
require 'socket' 
require 'timeout'

if ARGV.length < 4 or !ARGV.include?("-r")
  puts "Usage: scan_ports.rb <host> -r <range ports e.g. 1 100> [-f redirect output to a file named ports.txt]"
  exit 1
end

#the connection seconds to be estabilished
TIMEOUT = 2

#configure param, host, port start, port end
host =  ARGV[0]
port_s =  ARGV[2]
port_e =  ARGV[3]

#banner
puts "Port scan started " + host + " ports: " + port_s + "-" + port_e +  ", please wait...\n"

#results
open = []
filtered = []

# thread array	
thread = []

#process range ports
port_s.upto(port_e) do |port|
 # for each port append a thread
 thread << Thread.new do
	begin
		begin
		Timeout::timeout(TIMEOUT){
			TCPSocket.open(host,port)
			open.push port
		}
		# if there is no response the port is considered filtered
		rescue Timeout::Error
			filtered.push port
		end
	rescue Errno::ECONNREFUSED 
	end
	end
end

# wait the termination of each thread
thread.each { |th| th.join }

str_app = ""

if !open.empty?
	str_app = "Open ports: "
	#print on the same line
	str_app += open.join(" ")
 end
 
 if !filtered.empty?
	str_app += "\nFiltered ports: "
	str_app += filtered.join(" ")
 end
 
 #print result on the screen
 puts str_app
 
 #write output to the file
if ARGV.include?("-f")
 begin
  file = File.open("./ports.txt", "w")
  file.write("Port scan result for " + host + ", scanned ports: " + port_s + "-" + port_e + "\n" + str_app)
  puts "Scan result saved in file ports.txt"
 rescue IOError => e
  #some error occur, dir not writable etc...
  puts "An error occured creating the ports output file. " + e.to_s
 ensure
  file.close unless file.nil?
 end
end
 

 