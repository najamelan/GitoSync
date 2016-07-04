
module Gitomate
module Facts


# Options
#
# type       : "file", "directory", "characterSpecial", "blockSpecial", "fifo", "link", "socket", or "unknown"
# symlink    : boolean
# mode       : integer
# owner      : 'owner'
# group      : 'group'
# hashAlgo   : :SHA512
# hash       : string
#
class Path < Facts::Fact


attr_reader :path



def initialize( depend: [], **opts )

	super( Fact.config.options( :Facts, :Path ), opts, depend )

	@path = options( :path )
	@log  = Feedback.get 'Facts::Path', Fact.config

end



def analyze( update = false )

	super == 'return'  and  return @analyzePassed

	stat = File.stat path

	@symlink = stat.symlink?
	@type    = stat.ftype
	@mode    = stat.mode
	@uid     = stat.uid
	@gid     = stat.gid
	@owner   = Etc.getpwuid( @uid ).name
	@group   = Etc.getgrgid( @gid ).name

	@analyzed      = true
	@analyzePassed = true

end




def check( update = false )

	super == 'return'  and  return @checkPassed

	@checkPassed = true

	options.each do | key, target |

		case key

		when :type

			if target != @type

				@log.warn "[#{@path}] should be a #{target} but is a #{@type}"
				@checkPassed = false

			end

		end

	end

	@checked = true
	@checkPassed

end



def fix()

	super == 'return'  and  return @fixPassed

	raise "Note implemented"

end



end # class  Path
end # module Facts
end # module Gitomate
