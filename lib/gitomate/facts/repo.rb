
module Gitomate
module Facts


# Options (* means mandatory)
#
# path*       : Path to the repository directory (workingDir with .git)
# initialized : bool   (default=true)
#
class RepoInitialized < Facts::Fact

attr_reader :repo, :path


def initialize( path:, **opts )

	super( Fact.config.options( :Facts, :RepoInitialized ), opts, path: path )

	dependOn( Path, { path: path }, type: 'directory' )

	@repo = ::Gitomate::Repo.new( Fact.config, path: @path )

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

attr_reader :repo



def initialize( path:, **opts )

	super( Fact.config.options( :Facts, :Repo ), opts, path: path )

	@repo = ::Gitomate::Repo.new( Fact.config, path: @path )

	dependOn( RepoInitialized, { path: path } )

end



def analyze( update = false )

	super == 'return'  and  return @analyzePassed


	@state[ :branch ]  and  @state[ :branch ][ :found ] = @repo.branch
	@state[ :clean  ]  and  @state[ :clean  ][ :found ] = @repo.workingDirClean?

	@analyzePassed

end



def check( update = false )

	super == 'return'  and  return @checkPassed


	@state.each do | key, info |

		@options.has_key?( key ) or next

		info[ :passed ] = true

		if found( key ) != expect( key )

			info[ :passed ] = false
			@checkPassed    = false


			case key

			when :branch

				warn "#{@path.ai} should be on branch #{expect( key )}, but is on #{@state[ key ][ :found ].ai}."

			when :clean

				expect( key ) and warn "#{@path.ai} should have a clean working directory."
				expect( key ) or  warn "#{@path.ai} should NOT have a clean working directory."

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



# Options (* means mandatory)
#
# path*    : Path to the repository directory (workingDir with .git)
# name*    : string  (default=origin)
#
class RepoRemoteExist < Facts::Fact

attr_reader :repo



def initialize( path:, name:, **opts )

	super( Fact.config.options( :Facts, :RepoRemoteExist ), opts, path: path, name: name )

	dependOn( RepoInitialized, { path: path } )

	@repo    = ::Gitomate::Repo.new( Fact.config, path: @path )
	@remotes = @repo.remotes

end



def analyze( update = false )

	super == 'return'  and  return @analyzePassed

	@state[ :exist ][ :found ] = @remotes.include?( @name )

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

	expect( key )  and  warn "#{@path.ai} does not have a remote called: #{@name.ai}."
	expect( key )  or   warn "#{@path.ai} has a remote called: #{@name.ai} but it shouldn't."

	@checkPassed

end



def fix()

	super == 'return'  and  return @fixPassed

	raise "Note implemented"

end


end # class  RepoRemoteExist



# Options (* means mandatory)
#
# path*    : Path to the repository directory (workingDir with .git)
# name*    : string  (default=origin)
# url      : bool    (whether the working dir is clean)
# ahead    : bool    (will check for current branch)
# behind   : bool    (will check for current branch)
# diverged : bool    (will check for current branch)
#
class RepoRemote < Facts::Fact

attr_reader :repo



def initialize( path:, name:, merge: false, **opts )

	super( Fact.config.options( :Facts, :RepoRemote ), opts, path: path, name: name, merge: merge )

	dependOn( RepoRemoteExist, { path: path, name: name } )

	@repo   = ::Gitomate::Repo.new( Fact.config, path: @path )
	@remote = @repo.remotes[ name ]

end



def analyze( update = false )

	super == 'return'  and  return @analyzePassed


	@state[ :url      ]  and  @state[ :url      ][ :found ] = @remote.url
	@state[ :ahead    ]  and  @state[ :ahead    ][ :found ] = @remote.ahead?
	@state[ :behind   ]  and  @state[ :behind   ][ :found ] = @remote.behind?
	@state[ :diverged ]  and  @state[ :diverged ][ :found ] = @remote.diverged?

	@analyzePassed

end



def check( update = false )

	super == 'return'  and  return @checkPassed


	@state.each do | key, info |

		@options.has_key?( key ) or next

		info[ :passed ] = true

		if found( key ) != expect( key )

			info[ :passed ] = false
			@checkPassed    = false


			case key

			when :url

				warn "Remote #{@name.ai} of repo #{@path.ai} should have url #{expect( key )}, but has #{@state[ key ][ :found ].ai}."

			when :ahead

				expect( key ) and warn "#{@path.ai} should be ahead of remote #{@name.ai}."
				expect( key ) or  warn "#{@path.ai} should not be ahead of remote #{@name.ai}."

			when :behind

				expect( key ) and warn "#{@path.ai} should be behind of remote #{@name.ai}."
				expect( key ) or  warn "#{@path.ai} should not be behind of remote #{@name.ai}."

			when :diverged

				expect( key ) and warn "#{@path.ai} should be diverged of remote #{@name.ai}."
				expect( key ) or  warn "#{@path.ai} should not be diverged of remote #{@name.ai}."

			end


		end

	end


	@checkPassed

end



def fix()

	super == 'return'  and  return @fixPassed

	raise "Note implemented"

end


end # class  RepoRemote





end # module Facts
end # module Gitomate
