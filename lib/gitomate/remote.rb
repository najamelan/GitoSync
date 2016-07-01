
module Gitomate
class  Remote

include TidBits::Options::Configurable

def initialize( remote, default, userOpts = {} )

	setupOptions( default, userOpts )

	@log = Feedback.get( self.class.name )

	@rug       = remote
	@remoteUrl = remoteUrl

	@user, @host, @repoName = parseUrl
	@log.debug "parsed url - user: #{@user}, host: #{@host}, repoName: #{@repoName}"

	@sshConfig  = Net::SSH::Config.for 'localhost'
	@privateKey = @sshConfig[ :keys ][ 0 ]
	@publicKey  = "#{@privateKey}.pub"

	#@credentials = Rugged::Credentials::SshKey.new( username: @user, privatekey: @privateKey, publickey: @publicKey, passphrase: "" )
	@credentials = Rugged::Credentials::SshKeyFromAgent.new( username: 'root' )
end



def canConnect?

	pp @credentials
	pp @rug.url
	pp @rug.check_connection( :fetch )
	@rug.check_connection( :fetch )

end



def remoteUrl

	@remoteUrl and return @remoteUrl

	options( :remoteUrl ) != '%gituser@localhost:name%' and return options( :remoteUrl )

	# Placeholder, construct url
	#
	dummy = '%gituser@localhost:name%'

	dummy.gsub!( /%gituser/, options( :gituser ) )
	dummy.gsub!( /name%/   , options( :path ).scan( /[^\/]+$/ )[ 0 ] )

	@log.debug "Constructed remoteUrl: #{dummy}"
	dummy

end



def parseUrl

	@remoteUrl.match( /([^@]+)@([^:]+)\/(.+)/ ) do |matches|

		return matches[1], matches[2], matches[3]

	end

end


end # class  Remote
end # module Gitomate
