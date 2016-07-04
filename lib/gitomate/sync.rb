
module Gitomate

class Sync

include TidBits::Options::Configurable

def initialize( config, default, userOpts = {} )

	setupOptions( default, userOpts )

	@log   = Feedback.get( 'Sync  ', config )
	@repos = []

	options( :repos ).each do | repo |

		# @log.debug "Creating repo object for repo: #{repo[ :path ]}"
		@repos << Repo.new( config, repo )

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

		begin

			createPath       or next
			initRepo         or next
			# createWorkingDir or next
			# pathPermissions
			setRemote        # or next
			connectRemote    or next
			canWriteRemote
			onRightBranch
			workingDirClean
			# installHooks
			submodulesClean
			syncSubmodules
			syncWithBare
			repoPermissions

		rescue => e

			@log.error e
			next

		end

	end

end



def check( ok, warning, inform, &action )

	ok and return true
	@log.warn warning

	@dryRun and return false

	begin

		action.call

	rescue => e

		@log.error e
		return false

	end

	return true

end



def installGitolite



end



def configGitoUser



end



def createPath

	check                                                                \
                                                                        \
		  @repo.pathExists?                                               \
		, "The path for the repo #{@repo.paths} does not exist."          \
		, "Creating #{@repo.paths}"                                       \
                                                                        \
	                                                                     \
	do

		# create path

	end

end



def initRepo

	check                                                                \
                                                                        \
		  @repo.valid?                                                    \
		, "#{@repo.paths} does not contain a valid git repo."             \
		, "Creating #{@repo.paths}"                                       \
                                                                        \
	                                                                     \
	do

		raise "shouldn't be called"
		@repo.init

	end

end



def setRemote

	check                                                                \
                                                                        \
		  @repo.correctRemote?                                            \
		, "#{@repo.paths} does not have the correct remote set."          \
		, "Creating #{@repo.paths}"                                       \
                                                                        \
	                                                                     \
	do

		raise "shouldn't be called"
		@repo.fixRemote

	end

end



def connectRemote

	check                                                                \
                                                                        \
		  @repo.canConnect?                                               \
		, "#{@repo.paths} does not have a remote we can connect to."      \
		, "Bailing out, there's not much we can do"                       \
                                                                        \
	                                                                     \
	do

		@log.fatal "We can't connect to #{@repo.options( :remoteUrl )}"
		raise "This shouldn't happen"


	end

end



def canWriteRemote

	check                                                                \
                                                                        \
		  @repo.canWriteRemote?                                               \
		, "#{@repo.paths} does not have a remote we can write to."      \
		, "You should fix your permissions in gitolite-admin"             \
                                                                        \
	                                                                     \
	do

		@log.fatal "We can't write to #{@repo.options( :remoteUrl )}"
		raise "Fix your permissions in gitolite-admin"


	end

end



def onRightBranch

	check                                                                \
                                                                        \
		  @repo.onRightBranch?                                            \
		, "#{@repo.paths} does not have the correct branch checked out."  \
		, "Trying to check out #{@repo.options( :branch )}"               \
                                                                        \
	                                                                     \
	do

		# Try to check out the correct branch


	end

end



def workingDirClean

	check                                                                \
                                                                        \
		  @repo.workingDirClean?                                          \
		, "#{@repo.paths} does not have a clean working dir"              \
		, "Running `git add --all` and `git commit`"                      \
                                                                        \
	                                                                     \
	do

		# Try to commit all

	end

end



def installTrigger



end



def installHooks



end



def pathPermissions



end



def submodulesClean



end



def syncSubmodules



end



def syncWithBare



end



def repoPermissions



end




end # class  Sync
end # module Gitomate
