
module Gitomate
module Facts


# Options
#
# initialized : boolean
#
class RepoExist < Facts::Fact


attr_reader :repo



def initialize( depend: [], **opts )

	super( Fact.config.options( :Facts, :RepoExist ), opts, depend )

	@repo = options( :repo )
	@log  = Feedback.get 'Facts::RepoExist', Fact.config

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

					@log.warn "[#{@repo.path}] is a git repo but it shouldn't."
					@checkPassed = false

				end

			elsif target

				@log.warn "[#{@repo.path}] is not a git repo."
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



end # class  RepoExist
end # module Facts
end # module Gitomate
