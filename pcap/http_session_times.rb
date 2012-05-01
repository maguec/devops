#!/usr/bin/env ruby

require 'rubygems'
require 'pcaplet'

# run with IP and PCAP file as arguments

myip = ARGV[0]

sessions = {}

cap = Pcap::Capture.open_offline(ARGV[1])
cap.each_packet do |pkt|

  if pkt.src.to_s == myip
    sess_key = "#{pkt.src.to_s}:#{pkt.sport.to_s}->#{pkt.dst.to_s}:#{pkt.dport.to_s}"
  else
    sess_key = "#{pkt.dst.to_s}:#{pkt.dport.to_s}->#{pkt.src.to_s}:#{pkt.sport.to_s}"
  end

  if sessions.has_key?sess_key
    sessions[sess_key] << pkt
  else
    sessions[sess_key] = [ pkt ]
  end

end

cap.close

sessions.each do |k, v|
  url = ""
  v.each do |pkt|
    if pkt.tcp_data and pkt.tcp_data =~ /^(GET|POST)\s+(\S+)/
     url = $2
    end
  end
  if url != "/moov_check"
    all_times = v.collect { |x| x.time.to_f }
    puts "#{k}:#{url} => #{all_times.max - all_times.min}"
  end
end
