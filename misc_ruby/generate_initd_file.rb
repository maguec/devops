#!/usr/bin/env ruby1.8
##################################################################################
# == Synopsis
#
# blah
#
# == Usage
#
# blerg [OPTIONS]
#
# -h, --help:
#    show help

require 'erb'
require 'rubygems'
require 'getoptlong'
require 'rdoc/usage'



#   ERB template goes below

template = ERB.new <<-EOF
#!/bin/sh
### BEGIN INIT INFO
# Provides:          mystartup
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start daemon at boot time
# Description:       Enable service provided by daemon.
### END INIT INFO

ROOTDIR=<%= rootdir %>

<% if environvars != "" %>
#set environment variables
export <%= environvars %>
<% end %>

start_rails() {
	echo "Starting rails in $ROOTDIR"
	cd $ROOTDIR && script/server -e <%= railsenv %> -d -p <%= port %> <%= rootdir %>/<%= pidfile %>
}

stop_rails() {
	echo "Stopping rails in $ROOTDIR"
	cd $ROOTDIR && pid=`cat <%= rootdir %>/<%= pidfile %>`
	kill $pid
	if [ $? -ne "0" ] ; then
		echo "could not kill process $pid"
		exit 1
	fi

}

case $1 in
        start)
		start_rails
        ;;
        stop)
		stop_rails
        ;;
        restart)
		start_rails
		stop_rails
        ;;
esac
exit 0

EOF

################################################################################
opts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
  [ '--root-dir', '-r', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--pid-file', '-f', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--rails-env', '-e', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--port', '-p', GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--environment-vars', '-v', GetoptLong::OPTIONAL_ARGUMENT ]
)

railsenv = "production"
port = 3012
environvars = ""
rootdir = ""
pidfile = ""

opts.each do |opt, arg|
  case opt
    when '--help'
#      TODO: fix the rdoc usage stuff
#      RDoc::usage
#      exit(0)
    when '--root-dir'
      rootdir = arg
    when '--pid-file'
      pidfile = arg
    when '--rails-env'
      railsenv = arg
    when '--port'
      port = arg.to_i
    when '--environment-vars'
      environvars = arg
  end
end

puts template.result(binding)
