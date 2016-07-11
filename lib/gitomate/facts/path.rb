
module Gitomate
module Facts


# Options (* means mandatory)
#
# path* : Path to the repository directory (workingDir with .git)
# exist : bool   (default=true)
#
class PathExist < Facts::Fact

attr_reader :path


def initialize( path:, **opts )

	super( opts, path: path )

end


def analyze( update = false )

	super == 'return'  and  return @analyzePassed

	@state[ :exist ][ :found ] = File.exists? @path

	@analyzePassed

end



def check( update = false )

	super == 'return'  and  return @checkPassed

	key = :exist

	@state[ key ][ :passed ] = found( key ) == expect( key )  and  return @checkPassed

	# Failure
	#
	@checkPassed             = false
	@state[ key ][ :passed ] = false

	expect( key ) and warn "#{@path.inspect} does not exist."
	expect( key ) or  warn "#{@path.inspect} exists but it shouldn't."

	@checkPassed

end



def fix()

	super == 'return'  and  return @fixPassed

	raise "Note implemented"

end

end # class  PathExist


# Options (* means mandatory)
#
# path*      : string
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

attr_reader :path, :args



def initialize( path:, **opts )

	super( opts, path: path )

	dependOn( PathExist, { path: path }, type: options( :type ) )

end



def analyze( update = false )

	super == 'return'  and  return @analyzePassed


	stat = File.stat @path

	@state[ :symlink ]  and  @state[ :symlink ][ :found ] = stat.symlink?
	@state[ :type    ]  and  @state[ :type    ][ :found ] = stat.ftype
	@state[ :mode    ]  and  @state[ :mode    ][ :found ] = stat.mode
	@state[ :uid     ]  and  @state[ :uid     ][ :found ] = stat.uid
	@state[ :gid     ]  and  @state[ :gid     ][ :found ] = stat.gid
	@state[ :owner   ]  and  @state[ :owner   ][ :found ] = Etc.getpwuid( @state[ :uid ][ :found ] ).name
	@state[ :group   ]  and  @state[ :group   ][ :found ] = Etc.getgrgid( @state[ :gid ][ :found ] ).name


	@analyzePassed

end



def check( update = false )

	super == 'return'  and  return @checkPassed


	@state.each do | key, info |

		@options.has_key?( key ) or next

		if found( key ) != expect( key )

			info[ :passed ] = false
			@checkPassed    = false


			case key

			when :type

				warn "[#{@path}] should be a #{expect(key).ai} but is a #{found( key ).ai}"

			end


		end

	end


	@checkPassed

end



def fix()

	super == 'return'  and  return @fixPassed

	raise "Note implemented"

end



end # class  Path
end # module Facts
end # module Gitomate
