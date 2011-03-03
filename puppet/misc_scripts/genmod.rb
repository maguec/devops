#!/usr/bin/ruby
#
#############################################################################
# Quick Script to generate modes tree in 2.6.5
# change the module path to where you have your git repo checked out from git
# not in git?? see -> http://blog.mague.com/?p=77
#############################################################################
#

MODULE_PATH="#{ENV["HOME"]}/puppet_repo/modules"

modname = ARGV[0]

unless File.directory?MODULE_PATH
  puts "directory #{MODULE_PATH} does not exist"
  exit(1)
end

unless File.directory?"#{MODULE_PATH}/#{modname}"

  Dir.mkdir("#{MODULE_PATH}/#{modname}")

  ["manifests", "files", "templates"].each do |pdir| 
    Dir.mkdir("#{MODULE_PATH}/#{modname}/#{pdir}")
  end

  outstr = "class #{modname} \{\n\n\}\n"
  outfile = File.open("#{MODULE_PATH}/#{modname}/manifests/init.pp", 'w')
  outfile.write(outstr)
  outfile.close

end
