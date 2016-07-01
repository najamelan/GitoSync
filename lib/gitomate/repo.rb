
module Gitomate

class Repo

include TidBits::Options::Configurable



# The rush object for the repo path
#
attr_reader :path

# The string path for the repo
#
attr_reader :paths





def initialize( default = {}, userOpts = {} )

	super()

	setupOptions( default, userOpts )

	@log     = Feedback.get( self.class )
	@path    = Rush::Dir.new options[ :path ]
	@paths   = @path.to_s


	# Create a backend if the repo path exist and is a repo
	#
	begin

		@rug     = Rugged::Repository.new( @paths )
		@remotes = @rug.remotes

		# Create the remote if it exists in the repo
		#
		if @remotes[ options( :remote ) ]

			@remote = Remote.new( @remotes[ options( :remote ) ], defaults, userset )

		else

			@remote = nil

		end


	rescue Rugged::RepositoryError, Rugged::OSError

		@rug = @remotes = @remote = nil

	end

end


def pathExists?() @path.exists? end
def valid?	   () !!@rug        end



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



def workingDirClean?()

	@rug.diff_workdir( @rug.head.name ).size == 0

end


def diverged?()



end


def checkout()



end


def pullFF()



end

end # class  Repo
end # module Gitomate
