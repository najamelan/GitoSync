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
	dir = "/run/shm/#{ user.uid }/gitomate/#{ randomString }"

	FileUtils.mkpath( dir ).first

end



def dropPrivs

	uid        = Process.euid
	target_uid = Etc.getpwnam( @@user ).uid

	if uid != target_uid

		TidBits::Susu.su( user: @@user )

	end

end



def randomString

	rand( 36**8 ).to_s( 36 )

end



# Will create a clean repository in a tmp directory.
#
# The block will be called with the path to the repository and the name for the repository in gitolite
# Everything will be cleaned up when the block returns.
#
def cleanRepo &block

	block_given? or raise ArgumentError.new 'Need block'

	tmp       = tmpDir
	shortName = randomString
	repoName  = "gitomate/test/#{shortName}"
	repoPath  = "#{tmp}/#{shortName}"

	puts gitoCmd "create #{repoName}"

	Dir.chdir tmp

	puts `git clone #{@host}:#{repoName}`

	yield repoPath, repoName

ensure

	FileUtils.remove_entry_secure tmpDir

	puts gitoCmd "D unlock #{repoName}"
	puts gitoCmd "D rm     #{repoName}"

end



def gitoCmd( cmd )

	`ssh #{@host} #{cmd}`

end


end # class TestThorfile
end # module Gitomate
