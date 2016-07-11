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




desc 'install', 'Installs the application on the system'

def install

	setup options[ :profile ]

	begin

		here = Rush[ File.dirname( __FILE__ ) ]
		bins = here[ 'bin/*' ]

		bins.each do |bin|

			@binDirs.each do |dir|

				chmod bin.to_s, 755
				bin.symlink dir, force: true

			end
		end


		@confDirs.each do |dir|

			conf  = Rush::Dir.new( dir )

			conf.exists? or conf.create

		end


	rescue Errno::EACCES

		say 'ACCESS DENIED -- Are you root? Use sudo to install!'
		exit 1

	end

end



desc 'uninstall', 'Uninstalls the application from the system'

def uninstall

	setup options[ :profile ]

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

	require_relative 'test/run'

	setup :testing

	::Gitomate::TestSuite.run self

end


no_commands do

	def setup( profile )

		@config  = ::Gitomate::Config.new( profile )

		@log     = ::Gitomate::Feedback.get( 'Thorfile' )

		@binDirs  = @config.options( :install, :binDirs   )
		@binDirs.is_a?( Array ) or @binDirs = [ @binDirs ]

		@confDirs = @config.options( :install, :confDirs )
		@confDirs.is_a?( Array ) or @confDirs = [ @confDirs ]

	end

end



end # class gitomate
