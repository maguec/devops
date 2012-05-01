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
# -t, --threshold
#     threshold to alert for uptime
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
#require 'rdoc/usage'

PLUGIN_NAME = 'haproxystats'
#################################################################################
hostname = "localhost"
statspath = "/haproxy/stats;csv"
statname = "live"
threshold = 60
user = ""
pass = ""

opts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
  [ '--host', '-H', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--threshold', '-t', GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--path', '-P', GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--user', '-u', GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--password', '-p', GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--stats', '-s', GetoptLong::OPTIONAL_ARGUMENT ]
)

opts.each do |opt, arg|
  case opt
    when '--help'
#      RDoc::usage
      exit(0)
    when '--host'
      hostname = arg
    when '--threshold'
      threshold = arg.to_i
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

def collect_data(hostname, path, user, pass, statname, threshold)
  msg = ""
  status = 128
  url = URI.parse("http://#{hostname}#{path}")
  req = Net::HTTP::Get.new(url.path)
  if user != "" and pass != ""
    req.basic_auth(user, pass)
  end
  res = Net::HTTP.start(url.host, url.port) do |http|
    http.request(req)
  end
  if res.code == "200"
    status = 0
    CSV.parse(res.body) do |row|
      if row[0] == statname and row[1] !~ /[A-Z]{4,6}END/
        if row[17] =~ /^UP/ and row[23].to_i > threshold
          msg += "#{row[1]}: OK "
        else
          msg += "#{row[1]}: NOTOK "
          status = 1
        end
      end
    end
  end
  [status, msg]
end


check = collect_data(hostname, statspath, user, pass, statname, threshold)
puts check[1]
exit!check[0]

