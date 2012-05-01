#!/usr/bin/env ruby

myfile = File.open(ARGV[0], "r")

myfile.readlines.each do |line|
  if line =~ /^reqrep \S+ (\S+) \S+ (\d+\.\d+) (\d+\.\d+) (\d+\.\d+) \d+ \d+ \d+ [A-Z]{1,9} (.*)/
    if $4.to_f - $2.to_f > 0.2
      puts "#{$1}: #{$4.to_f - $2.to_f}: #{$5}"
    end
  end
end

