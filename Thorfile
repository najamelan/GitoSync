
require 'rubygems'
require 'thor'
require 'pp'

class  Gitosync < Thor

include Thor::Actions


@@configDir = '/etc/gitosync'


def self.source_root

  File.dirname( __FILE__ )

end



desc 'install', 'Installs the application on the system'

def install

	begin

		copy_file 'bin/gitosync', '/usr/local/bin/gitosync', { :force => true }

		create_file      @@configDir + '/config'
		empty_directory  @@configDir + '/config.d'

	rescue Errno::EACCES

		say 'ACCESS DENIED -- Are you root? Use sudo to install!'
		exit 1

	end

end



desc 'uninstall', 'Uninstalls the application from the system'

def uninstall

	begin

		remove_file '/usr/local/bin/gitosync'

	rescue Errno::EACCES

		say 'ACCESS DENIED -- Are you root? Use sudo to install!'
		exit 1

	end

end



desc 'purge', 'Uninstalls the application from the system AND REMOVES CONFIGURATION FILES IN /etc/gitosync !!!'

def purge

	begin

		remove_file '/usr/local/bin/gitosync'

		remove_file @@configDir + '/config'
		remove_file @@configDir + '/config.d'

	rescue Errno::EACCES

		say 'ACCESS DENIED -- Are you root? Use sudo to install!'
		exit 1

	end

end


no_commands do

end



end # class Gitosync
