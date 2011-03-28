module Puppet

  newtype(:gitdeploy) do
    @doc = "Deploy software using git.  Always do a git pull and only cue the restart if the software changed"

    newparam(:name) do
      desc "just keep track of this resource"
    end

    newparam(:repo_source) do
      desc "where we do the git pull from"
      #TODO -> add regexp or URL validation
    end

    newparam(:post_install) do
      desc "the command to run after the git clone"
    end

    newparam(:service_restart) do
      desc "the command to restart the service after a code update or git clone"
    end
#
    newparam(:repo_path) do
      desc "The filesystem path to checkout to"
      validate do |value|
        path = Pathname.new(value)
        unless path.absolute?
          raise ArgumentError, "Needs to be an absolute path #{path}"
        end
      end
    end

    newproperty(:ensure) do

      def retrieve
        if File.exists?(File.join(resource[:repo_path], ".git", "config") )
          gitpull
        else
          gitclone
        end
      end

      def gitpull 
        f = IO.popen("cd #{resource[:repo_path]} && /usr/bin/git pull origin ")
        if f.readlines[0] =~ /Already up\-to\-date\./
          f.close_read
          :present
        else
          f.close_read
          :absent
        end
      end

      def gitclone 
        clonewars = system("/usr/bin/git clone #{resource[:repo_source]} #{resource[:repo_path]} > /dev/null")
        if clonewars 
          if resource[:post_install] 
              postinstall
          end
          :absent
        else
          raise Puppet::Error, "Git clone of #{resource[:repo_source]} failed"
        end
      end

      def postinstall
        cmdout = system(resource[:post_install])
        unless cmdout
          raise Puppet::Error, "unsuccessfully ran command #{resource[:post_install]}"
        end
        servicerestart
        :absent
      end

      def servicerestart
        cmdout = system(resource[:service_restart])
        unless cmdout
          raise Puppet::Error, "unsuccessfully ran command #{resource[:service_restart]}"
        end
        :absent
      end

      newvalue :present do
        notice "Change to present"
      end

      newvalue :absent  do
        notice "Change to absent"
      end

    end

  end
end
