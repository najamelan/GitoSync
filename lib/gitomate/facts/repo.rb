
module Gitomate
module Facts


# Options (* means mandatory)
#
# path*       : Path to the repository directory (workingDir with .git)
# initialized : bool   (default=true)
#
class RepoInitialized < Facts::Fact


attr_reader :repo, :path


def initialize( **opts )

	super( Fact.config.options( :Facts, :RepoInitialized ), opts, :path )

	@path = options :path
	@repo = ::Gitomate::Repo.new( Fact.config, path: @path )

	dependOn( Path, path: @path, type: 'directory' )

end



def analyze( update = false )

	super == 'return'  and  return @analyzePassed

	@state[ :initialized ][ :found ] = @repo.valid?

	@analyzePassed

end



def check( update = false )

	super == 'return'  and  return @checkPassed

	key = :initialized

	@state[ key ][ :passed ] = found( key ) == expect( key )  and  return @checkPassed

	# Failure
	#
	@checkPassed             = false
	@state[ key ][ :passed ] = false

	expect( key )  and  warn "#{@repo.path.inspect} is not a git repo."
	expect( key )  or   warn "#{@repo.path.inspect} is a git repo but it shouldn't."

	@checkPassed

end



def fix()

	super == 'return'  and  return @fixPassed

	raise "Note implemented"

end

end # class  RepoInitialized




# Options (* means mandatory)
#
# path*       : Path to the repository directory (workingDir with .git)
# branch      : string
# clean       : bool    (whether the working dir is clean)
#
# TODO: currently we won't check anything if the initialized option doesn't correspond with reality.
#       However, we don't do input validation to keep people from asking us to test properties on a
#       repo that they claim should not be initialized, which might be confusing when they check the results.
#
#       In general we should have some sort of feedback mechanism to report the reason for failures to clients.
#
class Repo < Facts::Fact


attr_reader :repo, :path



def initialize( **opts )

	super( Fact.config.options( :Facts, :Repo ), opts, :path )

	@path = options :path
	@repo = ::Gitomate::Repo.new( Fact.config, path: @path )

	dependOn( RepoInitialized, path: @path )

end



def analyze( update = false )

	super == 'return'  and  return @analyzePassed

	@state[ :branch ][ :found ] = @repo.branch
	@state[ :clean  ][ :found ] = @repo.workingDirClean?

	@analyzePassed

end



def check( update = false )

	super == 'return'  and  return @checkPassed


	@state.each do | key, info |

		info[ :passed ] = true

		if found( key ) != expect( key )

			info[ :passed ] = false
			@checkPassed    = false


			case key

			when :branch

				warn "#{@repo.path.inspect} should be on branch #{target}, but is on #{@state[key].inspect}."

			when :clean

				warn "#{@repo.path.inspect} should have a clean working directory."

			end


		end

	end


	@checkPassed

end



def fix()

	super == 'return'  and  return @fixPassed

	raise "Note implemented"

end



end # class  Repo
end # module Facts
end # module Gitomate
