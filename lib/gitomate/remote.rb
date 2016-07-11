
module Gitomate
class  Remote

include TidBits::Options::Configurable

def initialize( config, rug, git, default, opts )

	setupOptions( opts )

	@log = Feedback.get( 'Remote', config )

	@git       = git
	@rug       = rug
	@remoteUrl = remoteUrl

	@user, @host, @repoName = parseUrl
	# @log.debug "parsed url - user: #{@user}, host: #{@host}, repoName: #{@repoName}"

	@sshConfig  = Net::SSH::Config.for 'localhost'
	@privateKey = @sshConfig[ :keys ].first
	@publicKey  = "#{@privateKey}.pub"

	@credentials = Rugged::Credentials::SshKey.new( username: @user, privatekey: @privateKey, publickey: @publicKey, passphrase: "" )

end



def canConnect?

	begin

		Git.ls_remote( @rug.url )

	rescue Git::GitExecuteError => e

		@log.error e
		return false

	end

	true

	# @rug.check_connection( :fetch )

end



def canWriteRemote?

	begin

		Net::SSH.start( @host, @user ) do |ssh|

			result = ssh.exec!("info etc")

			return result.include? "R W\t#{@repoName}"

		end

	rescue Net::SSH::AuthenticationFailed => e

		@log.error e
		return false

	end

end



def remoteUrl

	@remoteUrl and return @remoteUrl

	options( :remoteUrl ) != '%gituser%@localhost:%name%' and return options( :remoteUrl )

	# Placeholder, construct url
	#
	dummy = options( :remoteUrl )

	dummy.gsub!( /%gituser%/, options( :gituser ) )
	dummy.gsub!( /%name%/   , options( :path ).scan( /[^\/]+$/ ).first )

	@log.debug "Constructed remoteUrl: #{dummy}"
	dummy

end



def parseUrl

	@remoteUrl.match( /([^@]+)@([^:]+):(.+)/ ) do |matches|

		return matches[1], matches[2], matches[3]

	end

end



def fetch( branch )

	@git.fetch( options( :remote ) )

end


end # class  Remote
end # module Gitomate
