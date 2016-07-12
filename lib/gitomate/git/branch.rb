
module Gitomate
module Git


class  Branch

include TidBits::Options::Configurable


attr_reader :name, :upstream


def initialize( rug, rugRepo, git, **opts )

	setupOptions( opts )

	@log  = Feedback.get( self.class.name )

	@git        = git
	@rug        = rug
	@rugRepo    = rugRepo
	@name       = @rug.name
	@upstream   = @rug.upstream
	@remoteName = @rug.remote_name

end



def upstreamName

	@upstream or return nil

	@upstream.name

end



def divergence

	@name     or return nil
	@upstream   or return nil
	@remoteName or return nil

	@git.fetch( @remoteName )

	@rugRepo.ahead_behind( @name, @upstream.name )

end



def ahead

	divergence.is_a? Array or return nil

	divergence.first

end



def behind

	divergence.is_a? Array or return nil

	divergence.last

end



def ahead?    ; ahead or return nil; ahead   > 0 end
def behind?   ; ahead or return nil; behind  > 0 end


def diverged?

	ahead && behind  or  return nil

	ahead  != 0 && behind != 0

end


end # class  Repo
end # module Git
end # module Gitomate
