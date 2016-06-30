
module Gitomate

class Sync

include TidBits::Options::Configurable

def initialize( default, userOpts = {} )

	setupOptions( default, userOpts )

	@log   = Feedback.get( self.class )
	@repos = []

	options( :repos ).each do | repo |

		@log.debug "Creating repo object for repo: #{repo[ :path ]}"
		@repos << Repo.new( options( :repo ), repo )

	end

end



def sync( dryRun = true )

	@dryRun = dryRun

	installGitolite

	options( :gitusers ).each do |gitoUser|

		configGitoUser
		installTrigger

	end


	@repos.each do | repo |

		@repo = repo

		connectBare
		existInBare
		canWriteBare
		installHooks
		createPath
		pathPermissions
		onRightBranch
		submodulesClean
		workingDirClean
		syncSubmodules
		syncWithBare
		repoPermissions

	end

end



def installGitolite



end



def configGitoUser



end



def installTrigger



end



def connectBare

	if ! @repo.canConnect?

		@log.fatal "Can not connect to #{@repo.options( :bareUrl )}"

		raise

	end

end



def existInBare



end



def canWriteBare



end



def installHooks



end



def createPath



end



def pathPermissions



end



def onRightBranch



end



def submodulesClean



end



def workingDirClean



end



def syncSubmodules



end



def syncWithBare



end



def repoPermissions



end




end # class  Sync
end # module Gitomate
