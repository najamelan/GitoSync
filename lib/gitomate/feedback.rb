
module Gitomate

class Feedback

include TidBits::Options::Configurable

@@instance = {}


# Note that overriding options only works once for each progname
#
def self.get( progname, options = {} )

	@@instance[ progname ] || @@instance[ progname ] = self.new( progname, options )

end



def close

	@loggers.each { |logger| logger.close }

end



def msg2str( msg )

  case msg

  when String    then msg
  when Exception then "#{ msg.message } (#{ msg.class })\n" << ( msg.backtrace || [] ).join( "\n" )
  else                msg.inspect
  end

end



Logger::Severity.constants.each do |level|

	define_method( level.downcase ) do |*args|

		args.map! { |msg| msg2str( msg ) }
		args = [ args.join( "\n" ) ]

		@loggers.each { |logger| logger.send( level.downcase, args ) }

	end

end



private
def initialize( progname, options )

	@config  = Config.get
	userOpts = @config.userset( :feedback ) || {}
	userOpts.recursiveMerge! options

	setupOptions( @config.defaults( :feedback ), userOpts )


	@loggers = []

	options( :outputs ).each do | name, settings |

		settings[ :enabled ] || next

		case name

		when :file

			d = Rush::Dir.new( options( :logDir ) )
			d.exists? || d.create
			f = d[ options( :logFile ) ]

			l           = Logger.new( f.to_s, options( :keep ), options( :maxSize ) )
			l.level     = Logger::Severity.const_get( settings[ :logLevel ] )
			l.formatter = YamlLogFormat.new
			l.progname  = progname
			@loggers << l


		when :STDOUT

			l           = Logger.new( STDOUT )
			l.level     = Logger::Severity.const_get( settings[ :logLevel ] )
			l.formatter = CliLogFormat.new
			l.progname  = progname
			@loggers << l


		when :STDERR

			l           = Logger.new( STDERR )
			l.level     = Logger::Severity.const_get( settings[ :logLevel ] )
			l.formatter = CliLogFormat.new
			l.progname  = progname
			@loggers << l

		end

	end

end



end # class  Feedback
end # module Gitomate
