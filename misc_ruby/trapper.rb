#!/usr/bin/env ruby
#
# Find out what signal is getting sent to your process
# written to understand what monit/daemontools/runit are actually doing
#Signal.list   #=> {
#                   "EXIT"=>0, 
#                   "HUP"=>1, 
#                   "INT"=>2, 
#                   "QUIT"=>3, 
#                   "ILL"=>4, 
#                   "TRAP"=>5, 
#                   "IOT"=>6, 
#                   "ABRT"=>6, 
#                   "FPE"=>8, 
#                   "KILL"=>9, 
#                   "BUS"=>7, 
#                   "SEGV"=>11, 
#                   "SYS"=>31, 
#                   "PIPE"=>13, 
#                   "ALRM"=>14, 
#                   "TERM"=>15, 
#                   "URG"=>23, 
#                   "STOP"=>19, 
#                   "TSTP"=>20, 
#                   "CONT"=>18, 
#                   "CHLD"=>17, 
#                   "CLD"=>17, 
#                   "TTIN"=>21, 
#                   "TTOU"=>22, 
#                   "IO"=>29, 
#                   "XCPU"=>24, 
#                   "XFSZ"=>25, 
#                   "VTALRM"=>26, 
#                   "PROF"=>27, 
#                   "WINCH"=>28, 
#                   "USR1"=>10, 
#                   "USR2"=>12, 
#                   "PWR"=>30, 
#                   "POLL"=>29
#                   }
while 2 > 1 do
  Signal.trap("EXIT") do
    puts "EXIT"
  end
  Signal.trap("HUP") do
    puts "HUP"
  end
  Signal.trap("INT") do
    puts "INT"
  end
  Signal.trap("QUIT") do
    puts "QUIT"
  end
  Signal.trap("ILL") do
    puts "ILL"
  end
  Signal.trap("TRAP") do
    puts "TRAP"
  end
  Signal.trap("IOT") do
    puts "IOT"
  end
  Signal.trap("ABRT") do
    puts "ABRT"
  end
  Signal.trap("FPE") do
    puts "FPE"
  end
  Signal.trap("KILL") do
    puts "KILL"
    exit! 1
  end
  Signal.trap("BUS") do
    puts "BUS"
  end
  Signal.trap("SEGV") do
    puts "SEGV"
  end
  Signal.trap("SYS") do
    puts "SYS"
  end
  Signal.trap("PIPE") do
    puts "PIPE"
  end
  Signal.trap("ALRM") do
    puts "ALRM"
  end
  Signal.trap("TERM") do
    puts "TERM"
  end
  Signal.trap("URG") do
    puts "URG"
  end
  Signal.trap("STOP") do
    puts "STOP"
  end
  Signal.trap("TSTP") do
    puts "TSTP"
  end
  Signal.trap("CONT") do
    puts "CONT"
  end
  Signal.trap("CHLD") do
    puts "CHLD"
  end
  Signal.trap("CLD") do
    puts "CLD"
  end
  Signal.trap("TTIN") do
    puts "TTIN"
  end
  Signal.trap("TTOU") do
    puts "TTOU"
  end
  Signal.trap("IO") do
    puts "IO"
  end
  Signal.trap("XCPU") do
    puts "XCPU"
  end
  Signal.trap("XFSZ") do
    puts "XFSZ"
  end
  Signal.trap("VTALRM") do
    puts "VTALRM"
  end
  Signal.trap("PROF") do
    puts "PROF"
  end
  Signal.trap("WINCH") do
    puts "WINCH"
  end
  Signal.trap("USR1") do
    puts "USR1"
  end
  Signal.trap("USR2") do
    puts "USR2"
  end
  Signal.trap("PWR") do
    puts "PWR"
  end
  Signal.trap("POLL") do
    puts "POLL"
  end
end
