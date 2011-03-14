#!/usr/bin/env ruby
#################################################################################
# == Synopsis
#
# == Usage
# 
# haproxy.rb [OPTIONS]
#
# -h, --help:
#     Show help
#
# -H, --host
#     Haproxy Server to gather from 
#     default is localhost
#
# -i, --interval
#     Interval in seconds to collect stats for
#     default is 60
#
# -P, --path
#     Path to statistics page in haproxy
#     Set in haproxy config file
#        <stats enable>
#        <stats uri /stats/location>
#        <stats auth user:password>
#
# -u, --user
#     User to login as
#
# -p, --password
#     Password for user
#
# -s, --stats
#     name of the frontend and backend you are looking to gather stats on
#
#
#  Kudos to this site for getting me up and running
#  http://support.rightscale.com/12-Guides/RightScale_Methodologies/Monitoring_System/Writing_custom_collectd_plugins/Custom_Collectd_Plug-ins_for_Linux



require 'net/http'
require 'uri'
require 'csv'
require 'getoptlong'
require 'rdoc/usage'

PLUGIN_NAME = 'haproxystats'
#################################################################################
sampling_interval = 60
hostname = "localhost"
statspath = "/haproxy/stats;csv"
statname = "live"
user = ""
pass = ""

opts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
  [ '--host', '-H', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--interval', '-i', GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--path', '-P', GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--user', '-u', GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--password', '-p', GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--stats', '-s', GetoptLong::OPTIONAL_ARGUMENT ]
)

opts.each do |opt, arg|
  case opt
    when '--help'
      RDoc::usage
      exit(0)
    when '--host'
      hostname = arg
    when '--interval'
      sampling_interval = arg.to_i
    when '--path'
      statspath = arg
    when '--user'
      user = arg
    when '--password'
      pass = arg
    when '--stats'
      statname = arg
  end
end




$stdout.sync = true

def collect_data(hostname, path, user, pass, statname, start_run)
  url = URI.parse("http://#{hostname}#{path}")
  req = Net::HTTP::Get.new(url.path)
  if user != "" and pass != ""
    req.basic_auth(user, pass)
  end
  res = Net::HTTP.start(url.host, url.port) do |http|
    http.request(req)
  end
  if res.code == "200"
    CSV.parse(res.body) do |row|
      if row[0] == statname
	if ["FRONTEND", "BACKEND"].member?row[1]
	  puts "PUTVAL #{hostname}/haproxy-#{row[1].downcase}/counter-sessions #{start_run}:#{row[7]}"
	end
      end
    end
  end
end


while true do
  start_run = Time.now.to_i
  next_run = start_run + sampling_interval
  collect_data(hostname, statspath, user, pass, statname, start_run)
  while((time_left = (next_run - Time.now.to_i)) > 0) do
    sleep(time_left)
  end
end
