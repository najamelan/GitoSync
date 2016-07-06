
module Gitomate

class TestHelper


attr_reader :host, :prfx, :sshUser


def initialize

	@host    = 'gitcontent@localhost'
	@prfx    = 'gitomate/test/'
	@sshUser = 'gitomate'


end


def beSshUser

	beUser Etc.getpwnam( @sshUser ).uid, Etc.getpwnam( @sshUser ).gid

end


def beRoot

	beUser 0, 0

end


def beUser( euid, egid )

	Process.euid = euid
	# Process.egid = egid

end


end # class TestThorfile
end # module Gitomate
