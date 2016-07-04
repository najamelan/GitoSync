
module Gitomate

class Config

include TidBits::Options::Configurable

@@instance = nil



def self.get( profile = 'default', files = [] )

	@@instance or @@instance = self.new( profile, files )
	@@instance.dup

end


# This creates the Config object.
#
# First determine which configfiles to include.
# 1. The default config in installdir/conf + descendants
# 2. The config files specified in files passed on the command line + descendants
#
private
def initialize( profile, fromCmdLine = [] )

	@parsedFiles = []
	@profile     = profile.to_sym

	@profile == :include and raise "FATAL: The profile cannot be called [include]. Include is the only reserved name."


	# get options from <installDir>/conf into defaults
	#
	default = parseFiles File.expand_path( '../../../conf', __FILE__ )


	# If defaults reference more config files, put them in userCfg
	#
	fromFile = default.dig( :include )

	userCfg = deepParseFiles( fromFile )


	# Put everything from the files passed on the command line in extras
	#
	extras = deepParseFiles( fromCmdLine )


	# Override the userCfg with the extras
	#
	userCfg.recursiveMerge! extras


	# Merges them into options
	#
	setupOptions default, userCfg


	# Resolve the profile with it's inheritance and discard the rest
	#
	resolveInheritance


	# @@log ||= Feedback.get( 'Config' )

	# STDERR.puts "Parsed config files: #{@parsedFiles}"
	# STDERR.puts "Profile inheritance chain: #{@inheritance}"

	# pp options

end



def deepParseFiles( files )

	config = parseFiles files
	more   = config.dig :include

	more and config.recursiveMerge! deepParseFiles( more )
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

			config.recursiveMerge! parseFiles( file )
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


		config.recursiveMerge! loaded
		@parsedFiles << file

	end


	config

end



def resolveInheritance

	# The default profile is the root, it can't inherit
	#
	@profile == :default  and  return mergeProfiles

	profile = @profile
	@inheritance  = [ profile ]
	base    = @options.dig( profile, :inherit )

	base or return mergeProfiles


	base = base.to_sym

	while base != :default

		@options.dig base  or  STDERR.puts "WARNING: Config profile [#{profile}] tries to inherit from unexisting profile [#{base}]."

		@inheritance.include? base  and  raise "WARNING: Config profile [#{profile}] tries to inherit from profile [#{base}] but [#{base}] is already in the inheritance chain."

		@inheritance.unshift base

		profile = base

		base = @options.dig( profile, :inherit )
		base or break
		base = base.to_sym

	end

	mergeProfiles

end



def mergeProfiles

	@inheritance or @inheritance = []
	@inheritance.unshift :default


	@allDefaults = @defaults.dup
	@allUserset  = @userset .dup
	@allOptions  = @options .dup

	@defaults = {}
	@userset  = {}
	@options  = {}


	@inheritance.each do |parent|

		# We will extract only the content of the profiles, without keeping the rest, so in the end
		# we will only keep the currently running profile. The original will be stored in @allDefaults, etc.
		#
		@defaults.recursiveMerge!( @allDefaults.dig( parent ) || {} )
		@userset .recursiveMerge!( @allUserset .dig( parent ) || {} )
		@options .recursiveMerge!( @allOptions .dig( parent ) || {} )

	end

end

end # class  Config
end # module Gitomate
