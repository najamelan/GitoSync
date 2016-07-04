
module Gitomate
module Facts


# Options (* means mandatory)
#
# path* : string
# exist : boolean (default=true)
#
class PathExist < Facts::Fact


attr_reader :path



def initialize( depend: [], **opts )

	super( Fact.config.options( :Facts, :PathExist ), opts, depend )

	@path = options( :path )
	@log  = Feedback.get 'Facts::PathExist', Fact.config

end



def analyze( update = false )

	super == 'return'  and  return @analyzePassed

	@exist         = File.exists? @path
	@analyzed      = true
	@analyzePassed = true

end




def check( update = false )

	super == 'return'  and  return @checkPassed

	@checkPassed = true

	if !options( :exist )  &&  @exist

		@log.warn "[#{@path}] exists but it shouldn't."
		@checkPassed = false


	elsif options( :exist )  &&  !@exist

		@log.warn "[#{@path}] does not exist."
		@checkPassed = false

	end

	@checked = true
	@checkPassed

end



def fix()

	super == 'return'  and  return @fixPassed

	raise "Note implemented"

end



end # class  PathExist
end # module Facts
end # module Gitomate
