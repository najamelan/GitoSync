
module Gitomate
module Facts


# Options (* means mandatory)
#
# path*      : string
# exist      : boolean (default=true)
# type       : "file", "directory", "characterSpecial", "blockSpecial", "fifo", "link", "socket", or "unknown"
#              (default=file)
# symlink    : boolean
# mode       : integer
# owner      : 'owner'
# group      : 'group'
# mtime      :
# hashAlgo   : :SHA512
# hash       : string   the hash of the content
#
# TODO: currently we won't check anything if the exist option doesn't correspond with reality.
#       However, we don't do input validation to keep people from asking us to test properties
#       on a file that they claim should not exist, which might be confusing when they check the
#       results.
#
class Path < Facts::Fact


attr_reader :path



def initialize( **opts )

	super( Fact.config.options( :Facts, :Path ), opts )

	@info[ :path ] = options :path

end



def analyze( update = false )

	super == 'return'  and  return @analyzePassed

	@info[ :exist ] = File.exists? @info[ :path ]


	# These make no sense if the file doesn't exist
	#
	if @info[ :exist ]

		stat = File.stat @info[ :path ]

		@info[ :symlink ] = stat.symlink?
		@info[ :type    ] = stat.ftype
		@info[ :mode    ] = stat.mode
		@info[ :uid     ] = stat.uid
		@info[ :gid     ] = stat.gid
		@info[ :owner   ] = Etc.getpwuid( @info[ :uid ] ).name
		@info[ :group   ] = Etc.getgrgid( @info[ :gid ] ).name

	end

	@analyzed      = true
	@analyzePassed = true

end




def check( update = false )

	super == 'return'  and  return @checkPassed

	@checkPassed      = true
	@result[ :exist ] = true

	if options( :exist ) != @info[ :exist ]

		options( :exist ) and warn "#{@info[ :path ].inspect} does not exist."
		options( :exist ) or  warn "#{@info[ :path ].inspect} exists but it shouldn't."

		@checked            = true
		@result[ :exist ]   = false
		return @checkPassed = false

	end


	options.each do | key, target |

		case key

		when :type

			@result[ :type ] = true

			if target != @info[ :type ]

				warn "[#{@info[ :path ]}] should be a #{target.inspect} but is a #{@type.inspect}"

				@result[ :type ] = false
				@checkPassed     = false

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
