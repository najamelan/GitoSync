
module Gitomate
module Facts
module Git

# Options (* means mandatory)
#
# path*    : Path to the repository directory (workingDir with .git)
# name*    : string  (default=master)
#
class BranchExist < Facts::Fact

attr_reader :repo



def initialize( path:, name: 'master', **opts )

	super( opts, path: path, name: name )

	dependOn( RepoExist, { path: path } )

	@repo     = Gitomate::Git::Repo.new( path )
	@branches = @repo.branches


end



def analyze( update = false )

	super == 'return'  and  return @analyzePassed

	@state[ :exist ][ :found ] = @branches.include?( @name )

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

	expect( key )  and  warn "#{@path.ai} does not have a branch called: #{@name.ai}."
	expect( key )  or   warn "#{@path.ai} has a branch called: #{@name.ai} but it shouldn't."

	@checkPassed

end



def fix()

	super == 'return'  and  return @fixPassed

	raise "Note implemented"

end


end # class  BranchExist



# Options (* means mandatory)
#
# path*     : Path to the repository directory (workingDir with .git)
# name*     : string  (default=master)
# ahead?    : bool    (will check for current branch)
# behind?   : bool    (will check for current branch)
# diverged? : bool    (will check for current branch)
#
class Branch < Facts::Fact

attr_reader :repo



def initialize( path:, name:, **opts )

	super( opts, path: path, name: name )

	dependOn( BranchExist, { path: path, name: name } )

	options( :track ) and dependOn( BranchExist, { path: path, name: options( :track ) } )

	@repo   = Gitomate::Git::Repo.new( path )
	@branch = @repo.branches[ name ]

end



def analyze( update = false )

	super == 'return'  and  return @analyzePassed


	@state[ :track ]  and  @state[ :track ][ :found ] = @branch.upstreamName


	if @state[ :track ][ :found ]

		@state[ :ahead?    ]  and  @state[ :ahead?    ][ :found ] = @branch.ahead?
		@state[ :behind?   ]  and  @state[ :behind?   ][ :found ] = @branch.behind?
		@state[ :diverged? ]  and  @state[ :diverged? ][ :found ] = @branch.diverged?

	elsif @state[ :ahead? ] || @state[ :behind? ] || @state[ :diverged? ]

		warn "#{@path.ai} branch #{@name} should have an upstream, but it's not tracking anything."
		@analyzePassed = false

	end


	@analyzePassed

end



def check( update = false )

	super == 'return'  and  return @checkPassed


	@state.each do | key, info |

		# TODO:do we still need this check?
		#
		@options.has_key?( key ) or next

		info[ :passed ] = true

		if found( key ) != expect( key )

			info[ :passed ] = false
			@checkPassed    = false


			case key

			when :track

				expect( key ) and warn "#{@path.ai} branch #{@name} should track upstream #{    expect( key ).ai} but found found( key )."
				expect( key ) or  warn "#{@path.ai} branch #{@name} should not track upstream #{expect( key ).ai} but found found( key )."

			when :ahead?

				expect( key ) and warn "#{@path.ai} branch #{@name} should be ahead of #{    @state[ :track ][ :found ].ai}."
				expect( key ) or  warn "#{@path.ai} branch #{@name} should not be ahead of #{@state[ :track ][ :found ].ai}."

			when :behind?

				expect( key ) and warn "#{@path.ai} branch #{@name} should be behind of #{    @state[ :track ][ :found ].ai}."
				expect( key ) or  warn "#{@path.ai} branch #{@name} should not be behind of #{@state[ :track ][ :found ].ai}."

			when :diverged?

				expect( key ) and warn "#{@path.ai} branch #{@name} should be diverged of #{    @state[ :track ][ :found ].ai}."
				expect( key ) or  warn "#{@path.ai} branch #{@name} should not be diverged of #{@state[ :track ][ :found ].ai}."

			end


		end

	end


	@checkPassed

end



def fix()

	super == 'return'  and  return @fixPassed

	raise "Note implemented"

end


end # class  Branch




end # module Git
end # module Facts
end # module Gitomate
