
module Gitomate

class Config

include TidBits::Options::Configurable

# This creates the Config object.
#
# First determine which configfiles to include.
# 1. The default config in installdir/conf + descendants
# 2. The config files specified in files passed on the command line + descendants
#
def initialize( profile, fromCmdLine = [] )

	@parsedFiles = []
	@profile     = profile.to_sym

	@profile == :include and raise "FATAL: The profile cannot be called [include]. Include is the only reserved name."


	# get options from <installDir>/conf into defaults
	#
	default = parseFiles File.expand_path( '../../../conf', __FILE__ )


	# If defaults reference more config files, put them in userCfg
	#
	fromFile = default.dig(    :include )
	userCfg  = deepParseFiles( fromFile )


	# Put everything from the files passed on the command line in extras
	#
	extras = deepParseFiles( fromCmdLine )


	# Override the userCfg with the extras
	#
	userCfg.deep_merge! extras


	# Merges them into options
	#

	@allDefaults = default.deep_symbolize_keys
	@allUserset  = userCfg.deep_symbolize_keys
	@allOptions  = @allDefaults.deep_merge @allUserset

	# Resolve the profile with it's inheritance and discard the rest
	#
	resolveInheritance


	# Setup the defaults for all classes
	#
	setupDefaults profile


	# @@log ||= Feedback.get( 'Config' )

	# STDERR.puts "Parsed config files: #{@parsedFiles}"
	# STDERR.puts "Profile inheritance chain: #{@inheritance}"

	# pp options

end


def setupDefaults profile

	Feedback                .defaults = options( :Feedback            )
	# Sync                    .defaults = options( :Sync                )

	Git::Repo               .defaults = options( :Git  , :Repo        )
	Git::Remote             .defaults = options( :Git  , :Remote      )
	Git::Branch             .defaults = options( :Git  , :Branch      )

	Facts::Fact             .defaults = options( :Facts, :Fact        )
	Facts::PathExist        .defaults = options( :Facts, :PathExist   )
	Facts::Path             .defaults = options( :Facts, :Path        )

	Facts::Git::RepoExist   .defaults = options( :Facts, :Git, :RepoExist   )
	Facts::Git::Repo        .defaults = options( :Facts, :Git, :Repo        )
	Facts::Git::RemoteExist .defaults = options( :Facts, :Git, :RemoteExist )
	Facts::Git::Remote      .defaults = options( :Facts, :Git, :Remote      )
	Facts::Git::BranchExist .defaults = options( :Facts, :Git, :BranchExist )
	Facts::Git::Branch      .defaults = options( :Facts, :Git, :Branch      )

	profile == :testing or return

	TestFactRepo      .defaults = options( :TestFactRepo      )
	TestFactPathExist .defaults = options( :TestFactPathExist )
	TestAFact         .defaults = options( :TestAFact         )
	TestGitolite      .defaults = options( :TestGitolite      )
	TestTestHelper    .defaults = options( :TestTestHelper    )
	TestThorfile      .defaults = options( :TestThorfile      )

	Git::TestBranch   .defaults = options( :Git, :TestBranch  )

end


private

def deepParseFiles( files )

	config = parseFiles files
	more   = config.dig :include

	more and config.deep_merge! deepParseFiles( more )
	config

end



# Parses the configuration files
#
# @param  [String|Array<String>] files File or directory to parse or an array of such
# @return [Hash]
#
def parseFiles( files )

	files  = files.is_a?( Array ) ? files : [ files ]
	config = {}

	#pp files


	if files.length == 1 && File.directory?( files.first )

		files = Dir[ File.join( files.first, '**/*.yml') ]

	end


	files.each do |file|


		file = File.expand_path file

		if ! File.exist? file

			STDERR.puts "WARNING: Trying to load unexisting configuration file: #{ file }"
			STDERR.puts "Config files parsed so far: #{@parsedFiles}"

			next

		end


		if File.directory?( file )

			config.deep_merge! parseFiles( file )
			next

		end


		if @parsedFiles.include? file

			STDERR.puts "Trying to include configuration file twice: #{file}. Skipping..."
			next

		end


		loaded = YAML.load_file( file ).deep_symbolize_keys!

		if ! loaded.is_a?( Hash )

			STDERR.puts "Config file [#{file}] could not be parsed, it does not contain a Hash. Skipping..."
			next

		end


		config.deep_merge! loaded
		@parsedFiles << file

	end


	config

end



def resolveInheritance

	# The default profile is the root, it can't inherit
	#
	@profile == :default  and  return mergeProfiles

	profile       = @profile
	@inheritance  = [ profile ]
	base          = @allOptions.dig( profile, :inherit )

	base or return mergeProfiles


	base = base.to_sym

	while base != :default

		@allOptions.dig base  or  STDERR.puts "WARNING: Config profile [#{profile}] tries to inherit from unexisting profile [#{base}]."

		@inheritance.include? base  and  raise "WARNING: Config profile [#{profile}] tries to inherit from profile [#{base}] but [#{base}] is already in the inheritance chain."

		@inheritance.unshift base

		profile = base

		base = @allOptions.dig( profile, :inherit )
		base or break
		base = base.to_sym

	end

	mergeProfiles

end



def mergeProfiles

	@inheritance or @inheritance = []
	@inheritance.unshift :default


	defaults = {}
	userset  = {}
	options  = {}


	@inheritance.each do |parent|

		# We will extract only the content of the profiles, without keeping the rest, so in the end
		# we will only keep the currently running profile. The original will be stored in @allDefaults, etc.
		#
		defaults.deep_merge!( @allDefaults.dig( parent ) || {} )
		userset .deep_merge!( @allUserset .dig( parent ) || {} )
		options .deep_merge!( @allOptions .dig( parent ) || {} )

	end

	self.class.defaults = defaults
	setupOptions userset

end

end # class  Config
end # module Gitomate
