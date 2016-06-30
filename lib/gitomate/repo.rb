
module Gitomate

class Repo

include TidBits::Options::Configurable

def initialize( default, userOpts = {} )

	setupOptions( default, userOpts )

	@log  = Feedback.get( self.class )
	@path = Rush::Dir.new options[ :path ]
	@bare = createBare

	@log.debug( @path.to_s )

end


def createBare

	if options( :bareUrl ).include?( '@' )

		driver = BareSSH.new( {} )

	else

		raise NotImplementedError

	end


	Bare.new( driver, defaults, userset )

end


def canConnect?

	false

end


def pathExists?()



end


def workingDirClean?()



end


def diverged?()



end


def onRightBranch?()



end


def checkout()



end


def pullFF()



end

end # class  Repo
end # module Gitomate
