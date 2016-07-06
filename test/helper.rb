require 'etc'

module Gitomate

class TestHelper


attr_reader :host, :prfx, :sshUser, :user


def initialize

	@host    = 'gitcontent@localhost'
	@prfx    = 'gitomate/test/'
	@sshUser = 'gitomate'
	@@user   = 'gitomate'


end


def tmpDir

	user = Etc.getpwnam( @@user )
	dir = "/run/shm/#{ user.uid }/gitomate/#{ rand( 36**8 ).to_s( 36 ) }"

	FileUtils.mkpath( dir )

end



def dropPrivs

	uid        = Process.euid
	target_uid = Etc.getpwnam( @@user ).uid

	if uid != target_uid

		TidBits::Susu.su( user: @@user )

	end

end



def gitoCmd( cmd )

	`ssh #{@host} #{cmd}`

end


end # class TestThorfile
end # module Gitomate
