
module Gitomate
module Facts


# Options (* means mandatory)
#
# path*       : Path to the repository directory (workingDir with .git)
# initialized : bool   (default=true)
# branch      : string
# workDirClean: bool
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

	info[ :initialized  ]   = @repo.valid?


	if info[ :initialized ]

		info[ :branch       ]   = @repo.branch
		info[ :workDirClean ]   = @repo.workingDirClean?

	end


	@analyzed      = true
	@analyzePassed = true

end




def check( update = false )

	super == 'return'  and  return @checkPassed

	@checkPassed = true


	if options( :initialized )  !=  @info[ :initialized ]

		options( :initialized )  and  @log.warn "#{@repo.paths.inspect} is not a git repo."
		options( :initialized )  or   @log.warn "#{@repo.paths.inspect} is a git repo but it shouldn't."

		@checked = true
		return @checkPassed = false

	end


	options.each do | key, target |

		case key


		when :branch

			if @info[ :branch ] != target

				@log.warn "#{@repo.paths.inspect} should be on branch #{target}, but is on #{info[:branch].inspect}."
				@checkPassed = false

			end


		when :workDirClean

			if @info[ :workDirClean ] != target

				@log.warn "#{@repo.path.inspect} should have a clean working directory."
				@checkPassed = false

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
