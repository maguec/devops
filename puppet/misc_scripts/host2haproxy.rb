#!/usr/bin/env ruby
#
#

require 'erb'

begin
  template = ERB.new(File.open(ARGV[0]).read)
  myhosts = File.open(ARGV[1]).readlines
rescue Exception => e
  puts "Could not open file #{ARGV[0]} => #{e.message} "
end

mytargs = {}

myhosts.each do |line|
  if line =~ /(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s+(\S+)\s+USEME/
    mytargs[$2] = $1
  end
end

p mytargs

conf=File.open("/etc/haproxy/haproxy.cfg", 'w')
conf.puts template.result(binding)
conf.close
