
module Gitomate

class BareSSH

include TidBits::Options::Configurable

def initialize( default, userOpts = {} )

	setupOptions( default, userOpts )

	@log  = Feedback.get( self.class )

end

end # class  BareSSH
end # module Gitomate
