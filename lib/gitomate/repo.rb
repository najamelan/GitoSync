
module Gitomate

class Repo

include TidBits::Options::Configurable



# The rush object for the repo path
#
attr_reader :path

# The string path for the repo
#
attr_reader :paths





def initialize( config, **userOpts )

	setupOptions( config.options( :repo ), userOpts )

	@config  = config
	@log     = Feedback.get( self.class.name, @config )
	@path    = options[ :path ]

	# Create a backend if the repo path exist and is a repo
	#
	begin

		@rug      = Rugged::Repository.new( @path )
		@remotes  = @rug.remotes

		@git      = Git::Base.open @path


		# Create the remote if it exists in the repo
		#
		if @remotes[ options( :remote ) ]

			@remote = Remote.new( @config, @remotes[ options( :remote ) ], @git, defaults, userset )

		else

			@remote = nil

		end


	rescue Rugged::RepositoryError, Rugged::OSError

		@rug = @remotes = @remote = nil

	end

end


def pathExists?() File.exist? @path end
def valid?	   () !!@rug            end



def canConnect?

	@remote or return false

	@remote.canConnect?

end



def correctRemote?

	url = @rug.config[  "remote.#{options( :remote )}.url" ]

	url == options( :remoteUrl ) and return true

	return false

end



def canWriteRemote?

	@remote or return false

	@remote.canWriteRemote?

end



def onRightBranch?

	@rug.head.name == "refs/heads/#{ options( :branch ) }"

end



def branch

	begin

		@rug.head.name.remove( /refs\/heads\// )

	rescue Rugged::ReferenceError => e

		@log.warn "Could not find the reference HEAD points to in #{@path}"
		@log.warn "Possibly a repository without commits."
		@log.warn e
		nil

	end



end



def workingDirClean?()

	begin

		`git status -s`.lines.length == 0

		# Does not work
		# @rug.diff_workdir( @rug.head.name ).size == 0

	rescue Rugged::ReferenceError => e

		@log.warn "Could not find the reference HEAD points to in #{@path}"
		@log.warn "Possibly a repository without commits."
		@log.warn e
		nil

	end

end


def diverged?()

	ahead > 0 and behind > 0

end


def divergence

	@branch   or return nil
	@upBranch or return nil
	@remote   or return nil

	@remote.fetch( options( :branch ) )

	@rug.ahead_behind( @branch.name, @upBranch.name )

end


def ahead

	diff = divergence

	diff or return nil

	diff.first

end


def behind

	diff = divergence

	diff or return nil

	diff.last

end


def checkout()



end


def pullFF()



end

end # class  Repo
end # module Gitomate
