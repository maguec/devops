#!/usr/bin/env ruby

#################################################################################
# == Synopsis
#
# == Usage
# 
# memcache_mon.rb [OPTIONS]
# --host', '-H':
#   Host to connect to.  Defaults to 127.0.0.1
#
# --port', '-p':
#   Memcache port to connect to.  Defaults to 11211
#
# --state-file', '-f':
#   File that keeps state of byte counts. Default /tmp/memcache_state
#
# --warn-hitrate', '-W':
#   Warning threshold for cache hit rate. Default 10
#
# --crit-hitrate', '-C':
#   Critical threshold for cache hit rate. Default 5
#
# --warn-uptime', '-u':
#   Warning threshold for cache uptime in seconds. Default 600 
#   
# --crit-uptime', '-U':
#   Critical threshold for cache uptime in seconds. Default 300
#
#

require 'socket'
require 'getoptlong'
require 'rdoc/usage'

#set some defaults
hostname = "127.0.0.1"
port = 11211
exit_code = 512
warn_hitrate = 10.0
crit_hitrate = 5.0
warn_uptime = 600
crit_uptime = 300
state_file = "/tmp/memcache_state"
out_message = ""

opts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
  [ '--port', '-p', GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--state-file', '-f', GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--warn-hitrate', '-W', GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--crit-hitrate', '-C', GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--warn-uptime', '-u', GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--crit-uptime', '-U', GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--host', '-H', GetoptLong::REQUIRED_ARGUMENT ]
)

opts.each do |opt, arg|
  case opt
    when '--help'
      RDoc::usage
      exit(0)
    when '--host'
      hostname = arg
    when '--port'
      port = arg.to_i
    when '--state-file'
      state_file = arg
    when '--warn-hitrate'
      warn_hitrate = arg.to_f
    when '--crit-hitrate'
      crit_hitrate = arg.to_f
    when '--warn-uptime'
      warn_uptime = arg.to_i
    when '--crit-uptime'
      crit_uptime = arg.to_i
  end
end
#################################################################################
# check the sanity of warn vs. crit values
if crit_uptime > warn_uptime
  puts "The critical warning time needs to be less than or equal to the warning uptime"
  exit(2)
end
if crit_hitrate > warn_hitrate
  puts "The critical warning hitrate needs to be less than or equal to the warning hitrate"
  exit(2)
end

#################################################################################
myStats = Hash.new(0)

begin
  ks = TCPSocket.open(hostname, port)

  ks.puts "stats\nquit\n"
  while line =  ks.gets
    if line =~ /STAT\s+(\S+)\s+([0-9\.]{1,24})/
      myStats[$1.to_sym] = $2.to_f
    end
  end
  ks.close
  hitrate =  100 * myStats[:get_hits] / (myStats[:get_hits] + myStats[:get_misses])

rescue Exception => e
  puts "CRITICAL: #{e.message}"
  exit(2)
end

#################################################################################
#check the uptime first don't bother with any stats if it just came up

if myStats[:uptime] <= crit_uptime
  puts "CRITICAL: Uptime is less than #{crit_uptime} seconds"
  exit(2)
elsif myStats[:uptime] < warn_uptime
  puts "WARNING: Uptime is less than #{warn_uptime} seconds"
  exit(1)
end

if hitrate < crit_hitrate
  out_message += "CRITICAL: cache hitrate is less than #{crit_hitrate}"
  exit_code = 2
elsif hitrate <= warn_hitrate
  out_message += "WARNING: cache hitrate is less than #{crit_hitrate}"
  exit_code = 1
end

#################################################################################
# check to make sure bytes are flowing in and out of memcache
# write to state file
if File.exists?(state_file) and File.readable?(state_file)
  last_bytes = File.open(state_file).read.chomp.to_i
else
  begin
    File.open(state_file, 'w') { |x| x.puts "0" }
    last_bytes = 0
  rescue Exception => e
    puts "CRITICAL: #{state_file} error #{e.message}"
    exit(2)
  end
end


if myStats[:bytes_read] <= last_bytes
  out_message = "CRITICAL: no data flowing from memcached"
  exit_code = 2
end

begin
  File.open(state_file, 'w') { |x| x.puts myStats[:bytes_read] }
rescue Exception => e
  puts "CRITICAL: #{state_file} error #{e.message}"
  exit(2)
end

#################################################################################
#p myStats
#puts hitrate

if out_message == ""
  out_message = "OK: memcache checks out"
  exit_code = 0
end
puts out_message
exit(exit_code)

