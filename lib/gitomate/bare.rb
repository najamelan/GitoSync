
module Gitomate

class Bare

include TidBits::Options::Configurable

def initialize( driver, default, userOpts = {} )

	setupOptions( default, userOpts )

	@log    = Feedback.get( self.class )
	@driver = driver

end


end # class  Bare
end # module Gitomate
