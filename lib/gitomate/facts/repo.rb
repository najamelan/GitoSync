
module Gitomate
module Facts


# Options (* means mandatory)
#
# repo*       : A Gitomate::Repository object
# initialized : boolean (default=true)
#
class Repo < Facts::Fact


attr_reader :repo



def initialize( **opts )

	super( Fact.config.options( :Facts, :Repo ), opts )

	@repo = options( :repo )
	@log  = Feedback.get 'Facts::RepoExist', Fact.config

	dependOn( Path, path: @repo.paths, type: 'directory' )

end



def analyze( update = false )

	super == 'return'  and  return @analyzePassed

	@initialized   = @repo.valid?

	@analyzed      = true
	@analyzePassed = true

end




def check( update = false )

	super == 'return'  and  return @checkPassed

	@checkPassed = true


	options.each do | key, target |

		case key

		when :initialized

			if @initialized

				if !target

					@log.warn "#{@repo.paths.inspect} is a git repo but it shouldn't."
					@checkPassed = false

				end

			elsif target

				@log.warn "#{@repo.paths.inspect} is not a git repo."
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
