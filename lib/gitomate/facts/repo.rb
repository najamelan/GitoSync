
module Gitomate
module Facts


# Options (* means mandatory)
#
# path*       : Path to the repository directory (workingDir with .git)
# initialized : bool   (default=true)
# branch      : string
# clean       : bool    (whether the working dir is clean)
#
# TODO: currently we won't check anything if the initialized option doesn't correspond with reality.
#       However, we don't do input validation to keep people from asking us to test properties on a
#       repo that they claim should not initialized, which might be confusing when they check the results.
#
class Repo < Facts::Fact


attr_reader :repo



def initialize( **opts )

	super( Fact.config.options( :Facts, :Repo ), opts )

	@path = options( :path )
	@repo = ::Gitomate::Repo.new( Fact.config, path: @path )

	dependOn( Path, path: @path, type: 'directory' )

end



def analyze( update = false )

	super == 'return'  and  return @analyzePassed

	@info[ :initialized ]   = @repo.valid?


	if @info[ :initialized ]

		@info[ :branch ]   = @repo.branch
		@info[ :clean  ]   = @repo.workingDirClean?

	end


	@analyzed      = true
	@analyzePassed = true

end




def check( update = false )

	super == 'return'  and  return @checkPassed

	@checkPassed            = true
	@result[ :initialized ] = true

	if options( :initialized )  !=  @info[ :initialized ]

		options( :initialized )  and  warn "#{@repo.path.inspect} is not a git repo."
		options( :initialized )  or   warn "#{@repo.path.inspect} is a git repo but it shouldn't."

		@checked                = true
		@result[ :initialized ] = false
		return @checkPassed     = false

	end


	options.each do | key, target |

		case key


		when :branch

			@result[ :branch ] = true

			if @info[ :branch ] != target

				warn "#{@repo.path.inspect} should be on branch #{target}, but is on #{@info[:branch].inspect}."

				@result[ :branch ] = false
				@checkPassed       = false

			end


		when :clean

			@result[ :clean ] = true

			if @info[ :clean ] != target

				warn "#{@repo.path.inspect} should have a clean working directory."

				@result[ :clean ] = false
				@checkPassed      = false

			end

		end

	end

	@checked     = true
	@checkPassed

end



def fix()

	super == 'return'  and  return @fixPassed

	raise "Note implemented"

end



end # class  Repo
end # module Facts
end # module Gitomate
