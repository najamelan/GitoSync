require 'rubygems'
require 'thor'

require_relative 'lib/gitomate'


class Gitomate < Thor

include Thor::Actions



class_option                                \
                                            \
	  :profile                               \
	, aliases:  '-p'                         \
	, type:     :string                      \
	, default:  'default'                    \
	, desc:     'The config profile to use'  \




def initialize( *args )

	super

	pp "Using profile #{options[ :profile ]}"


	@config  = ::Gitomate::Config.get( options[ :profile ] )
	@binDir  = @config.options( :install, :binDir    )
	@confDir = @config.options( :install, :configDir )

end



desc 'install', 'Installs the application on the system'

def install

	begin

		here = Rush[ File.dirname( __FILE__ ) ]


		bins = here[ 'bin/*' ]

		bins.each do |bin|

			chmod bin.to_s, 755
			bin.symlink @binDir, force: true

		end


		conf  = Rush::Dir.new( @confDir )

		conf.exists? or conf.create


	rescue Errno::EACCES

		say 'ACCESS DENIED -- Are you root? Use sudo to install!'
		exit 1

	end

end



desc 'uninstall', 'Uninstalls the application from the system'

def uninstall

	begin

		here = Rush[ File.dirname( __FILE__ ) ]


		bins = here[ 'bin/*' ]

		bins.each do |bin|

			Rush::Dir.new( @binDir )[ bin.name ].destroy

		end

	rescue Errno::EACCES

		say 'ACCESS DENIED -- Are you root? Use sudo to install!'
		exit 1

	end

end



desc 'purge', 'Uninstalls the application from the system AND REMOVES CONFIGURATION FILES IN /etc/gitomate.d !!!'

def purge

	invoke :uninstall

	begin

		Rush::Dir.new( @confDir ).destroy

	rescue Errno::EACCES

		say 'ACCESS DENIED -- Are you root? Use sudo to install!'
		exit 1

	end

end



desc 'test', 'Run the unit tests for Gitomate. This will install the application since it also tests the installer.'

def test

	# invoke :install

	require_relative 'test/run'

	# ::Gitomate::TestSuite.run

end


no_commands do

end



end # class gitomate
