module MCollective
    module Agent
        class Nrpe<RPC::Agent
            metadata    :name        => "NRPE Agent",
                        :description => "run all nrpe checks",
                        :author      => "Chris Mague<github@mague.com>",
                        :license     => "DWYWI",
                        :version     => "0.1",
                        :url         => "https://github.com/maguec/devops/mcollective/nrpe",
                        :timeout     => 300

	    def has_nrpe()
	      File.exists?("/etc/nagios/nrpe.cfg")
	    end

	    def find_configs()
	      cfg_files = []
	      main_cfg = File.open("/etc/nagios/nrpe.cfg")
	      main_cfg.readlines.each do |line|
		if line =~ /^include=(.*)/
		  cfg_files << $1
		end
		if line =~ /^include_dir=(.*)/
		  Dir.glob("#{$1}/*.cfg").each { |x| cfg_files << x }
		end
	      end
	      main_cfg.close
	      cfg_files
	    end

	    def run_command(cmd)
	      cmdrun = IO.popen(cmd)
	      output = cmdrun.readlines
	      cmdrun.close
	      $?.to_i
	    end

	    def find_commands(cfgfiles)
	      commands = {}
	      cfgfiles.each do |cfgfile|
		cfg_file = File.open(cfgfile)
		cfg_file.readlines.each do |cline|
		  if cline =~ /^command\[(\S+)\]\=(.*)/
		    commands[$1] = $2
		  end
		end
		cfg_file.close
	      end
	      commands
	    end
	      

	    action "runall" do
	      unless has_nrpe
	        reply.fail "could not find nagios config"
	      end
	      results = {}
	      errors = []
	      commands = find_commands(find_configs)
	      commands.each do |name, cmd|
	        exit_code = run_command(cmd)
		results[name] = exit_code
		if exit_code > 0
		  errors << name
		end
	      end
	      if errors.length < 1
		reply[:info] = "OK"
	      else
		reply.fail = errors
	      end
	    end
            
        end
    end
end

# vi:tabstop=2:expandtab:ai:filetype=ruby
