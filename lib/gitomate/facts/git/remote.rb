
module Gitomate
module Facts
module Git

# Options (* means mandatory)
#
# path*    : Path to the repository directory (workingDir with .git)
# name*    : string  (default=origin)
#
class RemoteExist < Facts::Fact

attr_reader :repo



def initialize( path:, name:, **opts )

	super( opts, path: path, name: name )

	dependOn( RepoExist, { path: path } )

	@repo    = Gitomate::Git::Repo.new( path: path )
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


end # class  RemoteExist



# Options (* means mandatory)
#
# path*    : Path to the repository directory (workingDir with .git)
# name*    : string  (default=origin)
# url      : bool    (whether the working dir is clean)
# ahead    : bool    (will check for current branch)
# behind   : bool    (will check for current branch)
# diverged : bool    (will check for current branch)
#
class Remote < Facts::Fact

attr_reader :repo



def initialize( path:, name:, merge: false, **opts )

	super( opts, path: path, name: name, merge: merge )

	dependOn( RemoteExist, { path: path, name: name } )

	@repo   = Gitomate::Git::Repo.new( path: path )
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


end # class  Remote




end # module Git
end # module Facts
end # module Gitomate
