
module Gitomate

class Sync

include TidBits::Options::Configurable

def initialize( config, default, userOpts = {} )

	setupOptions( default, userOpts )

	@config = config
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


	@repos.each_with_index do | repo, key |

		@repo = repo
		o     = repo.options

		begin

			Facts::Fact.config = @config


			repo.addFact( :repoExist,  Facts::Repo.new(  repo:   repo  ) )

			# createPath
			# initRepo
			# # createWorkingDir
			# # pathPermissions
			# setRemote
			# connectRemote
			# canWriteRemote
			# onRightBranch
			# workingDirClean
			# # installHooks
			# submodulesClean
			# # syncSubmodules
			# pullRemote
			# pushRemote
			# repoPermissions
			#

			repo.checkAll

		rescue => e

			@log.error e
			next

		end

	end

end



def check( ok, warning, inform, depends, &action )

	if ok

		@success[ caller_locations(1).first.label.to_sym ] = true
		return true

	end

	@log.warn warning

	@dryRun and return false

	begin

		action.call or return false

	rescue => e

		@log.error e
		return false

	end

	@success[ caller_locations(1).first.label.to_sym ] = true
	return true

end



def installGitolite



end



def configGitoUser



end



def createPath

	Fact::Path.new( repo.options( :path ), @config.defaults, { exist: true, type: directory } )

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

	@success[ :createPath ] or return false

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

	@success[ :initRepo ] or return false

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

	@success[ :setRemote ] or return false

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

	@success[ :connectRemote ] or return false

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

	@success[ :initRepo ] or return false

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

	@success[ :onRightBranch ] or return false

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



def pullRemote

	@success[ :connectRemote ] && @success[ :workingDirClean ] or return false

	check                                                                \
                                                                        \
		  @repo.behind > 0                                                \
		, "#{@repo.paths} is behind remote"                               \
		, "Trying git pull fast forward only"                             \
                                                                        \
	                                                                     \
	do

		# Try to merge
		# @log.warn "pull ff"
		# try push --force

	end

end



def pushRemote

	@success[ :connectRemote ] && @success[ :workingDirClean ] or return false

	check                                                                \
                                                                        \
		  @repo.ahead > 0                                                 \
		, "#{@repo.paths} is ahead of remote."                            \
		, "Trying git pull fast forward only"                             \
                                                                        \
	                                                                     \
	do

		# Try to merge
		# @log.warn "push --force to sync remote"
		# try push --force

	end

end



def repoPermissions



end




end # class  Sync
end # module Gitomate
