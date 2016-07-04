
module Gitomate

class Repo

include TidBits::Options::Configurable



# The rush object for the repo path
#
attr_reader :path

# The string path for the repo
#
attr_reader :paths





def initialize( config, userOpts = {} )

	setupOptions( config.options( :repo ), userOpts )

	@config  = config
	@log     = Feedback.get( 'Repo   ', @config )
	@path    = Rush::Dir.new options[ :path ]
	@paths   = options[ :path ]
	@facts  = {}


	# Create a backend if the repo path exist and is a repo
	#
	begin

		@rug      = Rugged::Repository.new( @paths )

		@remotes  = @rug   .remotes
		@branch   = @rug   .branches()[ options( :branch ) ]
		@branch and @upBranch = @branch.upstream

		@git      = Git::Base.open @path.to_s

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


def addFact( name, check )

	@facts[ name ] = check

end


def fact( name )

	@facts[ name ]

end


def analyze( name )

	@facts[ name ].analyze

end


def check( name )

	@facts[ name ].check

end


def checkAll

	@facts.each { |key, fact| fact.check }

end


def fix( name )

	@facts[ name ].fix

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
