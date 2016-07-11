
module Gitomate
module Git


class  Remote

include TidBits::Options::Configurable


def initialize( rug, git, **opts )

	setupOptions( opts )

	@log = Feedback.get( self.class.name )

	@git = git
	@rug = rug
	@url = @rug.url

end

end # class  Repo
end # module Git
end # module Gitomate
