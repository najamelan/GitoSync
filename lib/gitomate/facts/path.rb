
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

	@checkPassed = true


	if  options( :exist )  !=  @info[ :exist ]

		options( :exist ) and @log.warn "#{@info[ :path ].inspect} does not exist."
		options( :exist ) or  @log.warn "#{@info[ :path ].inspect} exists but it shouldn't."

		@checked = true
		return @checkPassed = false

	end


	options.each do | key, target |

		case key

		when :type

			if target != @info[ :type ]

				@log.warn "[#{@info[ :path ]}] should be a #{target.inspect} but is a #{@type.inspect}"
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
